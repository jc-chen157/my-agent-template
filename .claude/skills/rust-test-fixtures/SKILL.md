# Rust Test Fixtures Skill

Organize reusable test helpers, fixtures, and shared setup in Rust projects.

## When to Use
- Tests share common setup logic
- Multiple modules need the same test infrastructure
- User says "refactor test setup" / "reduce test boilerplate" / "share test helpers"
- Setting up integration test infrastructure

---

## Fixture Organization Strategy

```
my_crate/
├── src/
│   ├── lib.rs
│   ├── order/
│   │   ├── mod.rs
│   │   ├── service.rs        # Unit tests in #[cfg(test)] mod tests { }
│   │   └── repository.rs
│   └── user/
│       └── service.rs
├── tests/                     # Integration tests (public API only)
│   ├── common/
│   │   └── mod.rs            # Shared helpers (NOT compiled as a test binary)
│   ├── order_lifecycle.rs
│   └── user_api.rs
└── Cargo.toml
```

### Decision Tree

```
Do multiple tests in THIS module share the same setup?
  ├── YES → Create helper functions in the #[cfg(test)] mod tests block
  └── NO  → Inline the setup

Do multiple MODULES in src/ share the same setup?
  ├── YES → Create a #[cfg(test)] test utility module in src/
  └── NO  → Keep it in the module's test block

Do integration tests (tests/) share the same setup?
  ├── YES → Create tests/common/mod.rs
  └── NO  → Inline in each integration test file
```

---

## Module-Level Test Helpers

Helper functions inside `#[cfg(test)]` blocks are only compiled during tests.

```rust
// src/order/service.rs

pub struct OrderService { /* ... */ }

impl OrderService {
    pub fn place_order(&self, order: Order) -> Result<OrderResult, OrderError> {
        // ...
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // ── Helpers ──────────────────────────────────────────

    fn sample_order() -> Order {
        Order {
            id: "test-order-1".into(),
            user_id: "test-user-1".into(),
            status: OrderStatus::Pending,
            items: vec![sample_item()],
        }
    }

    fn sample_item() -> Item {
        Item {
            sku: "ITEM-1".into(),
            qty: 1,
            price: 10.0,
        }
    }

    fn order_with_items(items: Vec<Item>) -> Order {
        Order {
            items,
            ..sample_order()
        }
    }

    fn order_with_status(status: OrderStatus) -> Order {
        Order {
            status,
            ..sample_order()
        }
    }

    fn setup_mocks() -> (MockOrderRepository, MockNotifier) {
        let repo = MockOrderRepository::new();
        let notifier = MockNotifier::new();
        // Caller binds as `let (mut repo, mut notifier)` and configures expectations per test.
        (repo, notifier)
    }

    // ── Tests ───────────────────────────────────────────

    #[test]
    fn test_place_order_success() {
        let order = sample_order();
        // ...
    }

    #[test]
    fn test_place_bulk_order() {
        let order = order_with_items(vec![
            Item { sku: "A".into(), qty: 10, price: 5.0 },
            Item { sku: "B".into(), qty: 20, price: 3.0 },
        ]);
        // ...
    }
}
```

Each helper should return a fresh value. Use `..sample_order()` (struct update syntax) for variants — Rust's equivalent of builder/functional options.

---

## Struct Update Syntax for Variants

Rust's struct update syntax (`..default()`) is the idiomatic way to create fixture variants.

```rust
fn sample_order() -> Order {
    Order {
        id: "test-1".into(),
        user_id: "user-1".into(),
        status: OrderStatus::Pending,
        items: vec![Item { sku: "A".into(), qty: 1, price: 10.0 }],
        created_at: Utc.with_ymd_and_hms(2025, 1, 1, 0, 0, 0).unwrap(),
    }
}

// Variants with selective overrides
let shipped = Order {
    status: OrderStatus::Shipped,
    ..sample_order()
};

let bulk = Order {
    items: vec![
        Item { sku: "X".into(), qty: 100, price: 1.0 },
    ],
    ..sample_order()
};
```

---

## Shared Integration Test Helpers (`tests/common/mod.rs`)

Files in `tests/` are each compiled as separate test binaries. A `common/` subdirectory with `mod.rs` is the idiomatic way to share helpers without creating an extra test binary.

```rust
// tests/common/mod.rs
use my_crate::{Item, Order, OrderStatus};

pub fn sample_order() -> Order {
    Order {
        id: "test-order-1".into(),
        user_id: "test-user-1".into(),
        status: OrderStatus::Pending,
        items: vec![Item {
            sku: "WIDGET".into(),
            qty: 3,
            price: 10.0,
        }],
    }
}

pub fn setup_test_db() -> TestDb {
    let url = std::env::var("TEST_DATABASE_URL")
        .unwrap_or_else(|_| "postgres://test:test@localhost:5432/testdb".into());

    let db = TestDb::connect(&url).expect("failed to connect to test database");
    db.run_migrations().expect("failed to run migrations");
    db
}

pub fn truncate_tables(db: &TestDb, tables: &[&str]) {
    for table in tables {
        db.execute(&format!("TRUNCATE TABLE {} CASCADE", table))
            .expect(&format!("failed to truncate {}", table));
    }
}
```

Keep table names fixed and test-owned in helpers like `truncate_tables`. Do not interpolate untrusted identifiers into SQL.

```rust
// tests/order_lifecycle.rs
mod common;

#[test]
fn test_create_and_confirm_order() {
    let db = common::setup_test_db();
    common::truncate_tables(&db, &["orders", "order_items"]);

    let order = common::sample_order();
    // ...
}
```

---

## rstest Fixtures

The `rstest` crate provides fixture injection similar to pytest.

```rust
use rstest::*;

#[fixture]
fn order_service() -> OrderService {
    let repo = InMemoryOrderRepo::new();
    let notifier = FakeNotifier::new();
    OrderService::new(Box::new(repo), Box::new(notifier))
}

#[fixture]
fn sample_order() -> Order {
    Order {
        id: "test-1".into(),
        user_id: "user-1".into(),
        status: OrderStatus::Pending,
        items: vec![Item { sku: "A".into(), qty: 1, price: 10.0 }],
        created_at: chrono::Utc::now(),
    }
}

#[rstest]
fn test_place_order(order_service: OrderService, sample_order: Order) {
    let result = order_service.place_order(sample_order).unwrap();
    assert_eq!(result.status, OrderStatus::Confirmed);
}

#[rstest]
fn test_empty_order_fails(order_service: OrderService) {
    let empty_order = Order {
        items: vec![],
        ..sample_order()
    };
    let result = order_service.place_order(empty_order);
    assert!(result.is_err());
}
```

### Fixture with Parameters

```rust
#[fixture]
fn order_with_status(#[default(OrderStatus::Pending)] status: OrderStatus) -> Order {
    Order {
        status,
        ..sample_order()
    }
}

#[rstest]
fn test_cancel_pending(order_with_status: Order) {
    // Uses default: Pending
}

#[rstest]
fn test_cannot_cancel_shipped(
    #[with(OrderStatus::Shipped)]
    order_with_status: Order,
) {
    // Uses: Shipped
}
```

Use `Default` in fixtures only when the type's default preserves valid domain invariants. If a valid value needs required IDs, timestamps, or nested data, prefer a concrete helper like `sample_order()`.

---

## Testcontainers

```rust
use testcontainers::runners::SyncRunner;
use testcontainers_modules::postgres::Postgres;

#[test]
fn test_with_postgres() {
    let container = Postgres::default().start().unwrap();

    let port = container.get_host_port_ipv4(5432).unwrap();
    let conn_str = format!("postgres://postgres:postgres@localhost:{}/postgres", port);

    let pool = PgPool::connect_lazy(&conn_str).unwrap();
    // Run migrations, execute tests...
    // Container is cleaned up when `container` is dropped
}
```

---

## Cleanup Patterns

| Pattern | Scope | Use for |
|---------|-------|---------|
| `Drop` trait | Automatic when value goes out of scope | Connection pools, temp files, containers |
| RAII guards | Scoped cleanup | Locks, temporary state |
| Table truncation before each test | Per test | Database isolation |
| Testcontainers drop | Per test/suite | Container lifecycle |

Rust's ownership model handles most cleanup automatically. Testcontainers are cleaned up when the container handle is dropped.

---

## When NOT to Create Shared Helpers

- Helper is used in only one test module — inline it in `mod tests`
- Helper hides important test setup logic — keep it visible
- Helper adds indirection without reducing duplication — skip it
- `..Default::default()` or struct update syntax is clearer than a builder only when the default value already represents a valid domain object

---

## Related Skills

- `rust-testing-patterns` - Built-in testing, rstest, mockall patterns
- `rust-test-engineer` - Comprehensive test review and coverage analysis
