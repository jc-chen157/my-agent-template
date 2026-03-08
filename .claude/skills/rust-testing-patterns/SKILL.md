# Rust Testing Patterns Skill

Built-in testing, rstest parameterized tests, mockall mocking, and idiomatic Rust testing patterns.

## When to Use
- Writing unit or integration tests in Rust
- Setting up mocks with mockall
- Structuring parameterized test cases with rstest
- User says "write tests" / "add tests" / "test this function"

---

## Framework Stack

| Tool | Purpose |
|------|---------|
| `#[test]` + `#[cfg(test)]` | Built-in test runner and conditional compilation |
| `rstest` (optional) | Parameterized tests (`#[case]`) and fixture injection |
| `mockall` (optional) | Trait-based mock generation (`#[automock]`) |
| `tokio::test` | Async test support for Tokio runtime |
| `cargo-llvm-cov` / `cargo-tarpaulin` | Coverage measurement |

Rust has strong built-in testing. Prefer plain tests and `assert!` macros. Reach for `rstest` and `mockall` when they reduce noise.

---

## Built-in Testing

### Unit Tests (Same File)

Unit tests live in a `#[cfg(test)]` module inside the source file. They can access private items.

```rust
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn internal_helper(x: i32) -> i32 {
    x * 2
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
    }

    #[test]
    fn test_add_negative() {
        assert_eq!(add(-1, 1), 0);
    }

    // Can test private functions — use judgment on whether this couples to implementation
    #[test]
    fn test_internal_helper() {
        assert_eq!(internal_helper(3), 6);
    }
}
```

### Integration Tests (`tests/` Directory)

Integration tests live in `tests/` at the project root. They test the public API only.

```
my_crate/
├── src/
│   └── lib.rs
├── tests/
│   ├── order_lifecycle.rs    # Each file is a separate test binary
│   ├── user_api.rs
│   └── common/
│       └── mod.rs            # Shared test helpers (not compiled as a test itself)
└── Cargo.toml
```

```rust
// tests/order_lifecycle.rs
use my_crate::OrderService;

#[test]
fn test_create_and_confirm_order() {
    let service = OrderService::new();
    let order = service.create("user-1", vec![("WIDGET", 3)]).unwrap();
    assert_eq!(order.status, "pending");

    let confirmed = service.confirm(&order.id).unwrap();
    assert_eq!(confirmed.status, "confirmed");
}
```

### Shared Test Helpers

```rust
// tests/common/mod.rs — shared across integration tests
pub fn setup_test_db() -> TestDb {
    // ...
}

pub fn sample_order() -> Order {
    Order {
        id: "test-1".into(),
        user_id: "test-user-1".into(),
        status: OrderStatus::Pending,
        items: vec![Item { sku: "A".into(), qty: 2, price: 10.0 }],
    }
}
```

```rust
// tests/order_lifecycle.rs
mod common;

#[test]
fn test_with_db() {
    let db = common::setup_test_db();
    // ...
}
```

### Doc Tests

Code examples in rustdoc comments are compiled and run as tests.

```rust
/// Adds two numbers together.
///
/// ```
/// use my_crate::add;
/// assert_eq!(add(2, 3), 5);
/// assert_eq!(add(-1, 1), 0);
/// ```
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

```bash
cargo test --doc  # Run doc tests only
```

---

## Assertions

### Standard Assertions

```rust
// Equality (requires Debug + PartialEq)
assert_eq!(result, expected);
assert_ne!(result, unexpected);

// Boolean condition
assert!(user.is_active());
assert!(!list.is_empty());

// Custom error messages
assert_eq!(
    order.total(), 150.0,
    "expected total 150.0 for order {:?}", order
);

assert!(
    result.is_ok(),
    "expected Ok but got: {:?}", result
);
```

### Testing Panics

Use `expected = "..."` when you need to distinguish the intended panic from other panic paths. Plain `#[should_panic]` is fine for simple invariants.

```rust
#[test]
#[should_panic]
fn test_divide_by_zero() {
    divide(10, 0);
}

#[test]
#[should_panic(expected = "division by zero")]
fn test_divide_by_zero_message() {
    divide(10, 0);
}
```

### Result-Based Tests

Return `Result` to use `?` operator for cleaner error handling in tests.

```rust
#[test]
fn test_parse_config() -> Result<(), Box<dyn std::error::Error>> {
    let config = parse_config("key=value")?;
    assert_eq!(config.get("key"), Some(&"value".to_string()));
    Ok(())
}
```

### Testing Result and Option Values

```rust
#[test]
fn test_find_user() {
    let result = repo.find_by_id("user-1");

    assert!(result.is_ok());
    let user = result.unwrap();
    assert_eq!(user.name, "Alice");
}

#[test]
fn test_find_missing_user() {
    let result = repo.find_by_id("nonexistent");

    assert!(result.is_err());
    let err = result.unwrap_err();
    assert!(matches!(err, RepoError::NotFound(_)));
}

#[test]
fn test_optional_field() {
    let user = User::new("Alice");
    assert!(user.email.is_none());

    let user = user.with_email("alice@test.com");
    assert_eq!(user.email, Some("alice@test.com".to_string()));
}
```

---

## Parameterized Tests with rstest

### Basic Cases

```rust
use rstest::rstest;

#[rstest]
#[case(0, 0)]
#[case(1, 1)]
#[case(2, 1)]
#[case(3, 2)]
#[case(4, 3)]
fn test_fibonacci(#[case] input: u32, #[case] expected: u32) {
    assert_eq!(fibonacci(input), expected);
}
```

### Named Cases

```rust
#[rstest]
#[case::valid_email("user@example.com", true)]
#[case::missing_at("invalid-email", false)]
#[case::empty_string("", false)]
#[case::no_domain("user@", false)]
fn test_is_valid_email(#[case] email: &str, #[case] expected: bool) {
    assert_eq!(is_valid_email(email), expected);
}
```

### rstest Fixtures

```rust
use rstest::*;

#[fixture]
fn order_service() -> OrderService {
    let repo = InMemoryOrderRepo::new();
    OrderService::new(repo)
}

#[rstest]
fn test_create_order(order_service: OrderService) {
    let order = order_service.create("user-1", vec![("A", 2)]).unwrap();
    assert_eq!(order.status, "pending");
}

#[rstest]
fn test_empty_order_fails(order_service: OrderService) {
    let result = order_service.create("user-1", vec![]);
    assert!(result.is_err());
}
```

### Parametrize with Expected Errors

```rust
#[rstest]
#[case::negative(-1.0, "must be positive")]
#[case::zero(0.0, "must be positive")]
fn test_rejects_invalid_amount(#[case] amount: f64, #[case] expected_msg: &str) {
    let result = process_payment(amount);
    assert!(result.is_err());
    let err = result.unwrap_err();
    assert!(err.to_string().contains(expected_msg));
}
```

---

## Mocking with mockall

### Trait-Based Mocking

Define traits for dependencies, then use `#[automock]` to generate mocks.

```rust
use mockall::automock;

#[automock]
pub trait OrderRepository {
    fn save(&self, order: &Order) -> Result<Order, RepoError>;
    fn find_by_id(&self, id: &str) -> Result<Option<Order>, RepoError>;
}

#[automock]
pub trait NotificationSender {
    fn send(&self, recipient: &str, message: &str) -> Result<(), NotifyError>;
}
```

### Per-Test Mock Setup

```rust
#[cfg(test)]
mod tests {
    use super::*;
    use mockall::predicate::*;

    #[test]
    fn test_place_order_success() {
        let mut mock_repo = MockOrderRepository::new();
        let mut mock_notifier = MockNotificationSender::new();

        mock_repo
            .expect_save()
            .with(always())
            .times(1)
            .returning(|order| Ok(order.clone()));

        mock_notifier
            .expect_send()
            .with(eq("user@test.com"), always())
            .times(1)
            .returning(|_, _| Ok(()));

        let service = OrderService::new(
            Box::new(mock_repo),
            Box::new(mock_notifier),
        );

        let result = service.place_order(sample_order());
        assert!(result.is_ok());
        assert_eq!(result.unwrap().status, "confirmed");
    }

    #[test]
    fn test_place_order_repo_fails() {
        let mut mock_repo = MockOrderRepository::new();
        let mock_notifier = MockNotificationSender::new();

        mock_repo
            .expect_save()
            .returning(|_| Err(RepoError::ConnectionLost));

        let service = OrderService::new(
            Box::new(mock_repo),
            Box::new(mock_notifier),
        );

        let result = service.place_order(sample_order());
        assert!(result.is_err());
        // Notifier should NOT have been called
    }
}
```

### When to Use Mocks vs Fakes

| Approach | Use when |
|----------|----------|
| `MockXxx` (mockall) | Complex expectation verification (call count, argument matching) |
| Hand-written fakes | Simple in-memory implementations (e.g., `InMemoryRepo`) |
| Real implementations | Fast, deterministic dependencies (e.g., in-memory DB) |

Prefer the simplest option that gives clear test feedback. Over-mocking couples tests to implementation.

---

## Async Testing

### tokio::test

```rust
#[tokio::test]
async fn test_fetch_user() {
    let client = MockHttpClient::new();
    // setup expectations...

    let service = UserService::new(Box::new(client));
    let user = service.fetch_user("user-1").await.unwrap();

    assert_eq!(user.name, "Alice");
}
```

### Time-Sensitive Tests

```rust
#[tokio::test(start_paused = true)]
async fn test_timeout_behavior() {
    let result = tokio::time::timeout(
        Duration::from_secs(5),
        long_running_task(),
    ).await;

    assert!(result.is_err()); // Timed out
}
```

### Async with rstest

```rust
#[rstest]
#[tokio::test]
async fn test_async_order(order_service: OrderService) {
    let order = order_service.create_async("user-1").await.unwrap();
    assert_eq!(order.status, "pending");
}
```

---

## Test Organization

### Directory Structure

```
src/
├── lib.rs
├── order/
│   ├── mod.rs
│   ├── service.rs          # Contains #[cfg(test)] mod tests { ... }
│   └── repository.rs       # Contains #[cfg(test)] mod tests { ... }
tests/                       # Integration tests (public API only)
├── common/
│   └── mod.rs              # Shared helpers
├── order_lifecycle.rs
└── user_api.rs
```

### Running Tests

```bash
# All tests
cargo test

# Specific test
cargo test test_place_order

# Tests in a module
cargo test order::service::tests

# Integration tests only
cargo test --test order_lifecycle

# Doc tests only
cargo test --doc

# With output (println! visible)
cargo test -- --nocapture

# Run ignored tests
cargo test -- --ignored
```

---

## Rust-Specific Idioms

### Property-Based Testing with proptest

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_parse_roundtrip(s in "[a-zA-Z0-9]{1,100}") {
        let encoded = encode(&s);
        let decoded = decode(&encoded).unwrap();
        assert_eq!(s, decoded);
    }

    #[test]
    fn test_sort_preserves_length(mut vec in prop::collection::vec(any::<i32>(), 0..100)) {
        let original_len = vec.len();
        vec.sort();
        assert_eq!(vec.len(), original_len);
    }
}
```

### Snapshot Testing with insta

```rust
use insta::assert_snapshot;
use insta::assert_debug_snapshot;

#[test]
fn test_render_report() {
    let report = generate_report(&sample_data());
    assert_snapshot!(report);
    // First run: creates snapshot file
    // Subsequent runs: compares against snapshot
}

#[test]
fn test_parse_config() {
    let config = parse_config("input.yaml").unwrap();
    assert_debug_snapshot!(config);
}
```

```bash
# Review and accept snapshot changes
cargo insta review
```

### Testing with Miri (Unsafe Code)

```bash
# Detect undefined behavior in unsafe code
cargo +nightly miri test
```

---

## Coverage

### cargo-llvm-cov (Recommended)

```bash
# Install
cargo install cargo-llvm-cov

# Run with coverage
cargo llvm-cov

# HTML report
cargo llvm-cov --html
# Report at: target/llvm-cov/html/index.html

# JSON report (for CI)
cargo llvm-cov --json --output-path coverage.json

# With branch coverage
cargo llvm-cov --branch
```

### cargo-tarpaulin (Linux)

```bash
# Install
cargo install cargo-tarpaulin

# Run with coverage
cargo tarpaulin

# HTML report
cargo tarpaulin --out Html
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Do Instead |
|--------------|---------|------------|
| Over-mocking | Couples tests to implementation | Use fakes or real implementations when simple |
| Only testing happy paths | Misses error handling bugs | Test `Err`, `None`, panics, and edge cases |
| `unwrap()` in production code | Panics at runtime | Use `?`, `map_err`, `unwrap_or`, `expect` with context |
| Exposing private state for tests | Breaks encapsulation | Test behavior via public API; use `#[cfg(test)]` helpers sparingly |
| Skipping cleanup assertions when cleanup is part of behavior | Resource leaks can slip through | Verify cleanup semantics with focused tests or helpers |
| Bare `#[should_panic]` when multiple panic sources exist | Harder to distinguish the real panic path | Add `expected = "message"` when disambiguation matters |
| Shared mutable state between tests | Flaky, order-dependent | Each test builds its own state |
| Ignoring `cargo test -- --nocapture` | Missing debug output | Use `--nocapture` when debugging |
| `thread::sleep` in tests | Flaky, slow | Use `tokio::test(start_paused = true)` or channels |
| Not running `cargo test` with `--release` occasionally | Misses optimization-dependent bugs | Test in both debug and release periodically |

---

## Related Skills

- `rust-test-fixtures` — Test helper organization and shared setup patterns
- `rust-test-engineer` — Comprehensive test review and coverage analysis
