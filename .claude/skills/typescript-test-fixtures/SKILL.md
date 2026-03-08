# TypeScript Test Fixtures Skill

Organize reusable test helpers, fixtures, and shared setup in TypeScript projects.

## When to Use
- Tests share common setup logic
- Multiple test files need the same infrastructure (e.g., database, API mocks)
- User says "refactor test setup" / "reduce test boilerplate" / "share test helpers"
- Setting up integration test infrastructure

---

## Fixture Organization Strategy

```
src/
├── services/
│   ├── orderService.ts
│   └── orderService.test.ts       # Co-located unit tests
├── utils/
│   ├── validation.ts
│   └── validation.test.ts
├── __tests__/                      # Integration / cross-cutting tests
│   └── integration/
│       ├── orderApi.test.ts
│       └── userApi.test.ts
└── test/                           # Shared test utilities
    ├── fixtures/
    │   ├── orderFixtures.ts
    │   └── userFixtures.ts
    ├── helpers/
    │   ├── dbHelper.ts
    │   └── httpHelper.ts
    ├── mocks/
    │   ├── handlers.ts             # MSW handlers
    │   └── server.ts               # MSW server setup
    └── setup.ts                    # Global test setup
```

### Decision Tree

```
Do multiple tests in THIS file share the same setup?
  ├── YES → Use beforeEach or a local helper function
  └── NO  → Inline the setup

Do multiple FILES share the same setup?
  ├── YES → Create a shared helper in test/helpers/ or test/fixtures/
  └── NO  → Keep it local to the test file

Is this setup for API/HTTP mocking?
  ├── YES → Put MSW handlers in test/mocks/
  └── NO  → Use test/helpers/ or test/fixtures/
```

---

## Fixture Builders

### Factory Functions (Preferred)

```typescript
// test/fixtures/orderFixtures.ts

export function createOrder(overrides: Partial<Order> = {}): Order {
  return {
    id: "test-order-1",
    userId: "test-user-1",
    status: "pending",
    items: [createItem()],
    createdAt: new Date("2025-01-01T00:00:00Z"),
    ...overrides,
  };
}

export function createItem(overrides: Partial<Item> = {}): Item {
  return {
    sku: "ITEM-1",
    qty: 1,
    price: 10.0,
    ...overrides,
  };
}

export function createUser(overrides: Partial<User> = {}): User {
  return {
    id: "test-user-1",
    name: "Alice",
    email: "alice@test.com",
    role: "user",
    ...overrides,
  };
}
```

### Usage in Tests

```typescript
import { createOrder, createItem } from "../../test/fixtures/orderFixtures";

describe("OrderService", () => {
  test("places standard order", async () => {
    const order = createOrder();
    // ...
  });

  test("applies discount for bulk order", async () => {
    const order = createOrder({
      items: [
        createItem({ sku: "A", qty: 10, price: 5.0 }),
        createItem({ sku: "B", qty: 20, price: 3.0 }),
      ],
    });
    // ...
  });

  test("rejects shipped order cancellation", async () => {
    const order = createOrder({ status: "shipped" });
    // ...
  });
});
```

Each call returns a fresh object. `Partial<T>` + spread gives type-safe overrides — TypeScript's idiomatic equivalent of builder patterns.

---

## Lifecycle Hooks

### beforeEach / afterEach (Per-Test Setup)

```typescript
describe("OrderService", () => {
  let service: OrderService;
  let mockRepo: MockProxy<OrderRepository>;

  beforeEach(() => {
    // Fresh state per test
    mockRepo = mock<OrderRepository>();
    service = new OrderService(mockRepo);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  test("places order", async () => {
    mockRepo.save.mockResolvedValue(createOrder({ status: "confirmed" }));
    const result = await service.placeOrder(createOrder());
    expect(result.status).toBe("confirmed");
  });
});
```

### beforeAll / afterAll (Expensive Shared Setup)

Use only for immutable expensive resources (containers, server instances). Keep mutable state in `beforeEach`.

```typescript
describe("OrderRepository", () => {
  let container: StartedPostgreSqlContainer;
  let pool: Pool;

  beforeAll(async () => {
    container = await new PostgreSqlContainer().start();
    pool = new Pool({ connectionString: container.getConnectionUri() });
  }, 30_000); // Extended timeout for container startup

  afterAll(async () => {
    await pool.end();
    await container.stop();
  });

  let repo: OrderRepository;

  beforeEach(async () => {
    // Per-test: clean state
    await pool.query("TRUNCATE TABLE orders CASCADE");
    repo = new OrderRepository(pool);
  });

  test("saves and retrieves order", async () => {
    const saved = await repo.save(createOrder());
    const found = await repo.findById(saved.id);
    expect(found).toMatchObject({ status: "pending" });
  });
});
```

---

## MSW (Mock Service Worker) Setup

### Centralized Handlers

```typescript
// test/mocks/handlers.ts
import { http, HttpResponse } from "msw";

export const handlers = [
  http.get("/api/users/:id", ({ params }) => {
    return HttpResponse.json({
      id: params.id,
      name: "Alice",
      email: "alice@test.com",
    });
  }),

  http.post("/api/orders", async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: "order-123", status: "confirmed", ...body },
      { status: 201 },
    );
  }),
];
```

```typescript
// test/mocks/server.ts
import { setupServer } from "msw/node";
import { handlers } from "./handlers";

export const server = setupServer(...handlers);
```

### Global Setup

```typescript
// test/setup.ts
import { server } from "./mocks/server";

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    setupFiles: ["./test/setup.ts"],
  },
});
```

### Per-Test Overrides

```typescript
import { server } from "../../test/mocks/server";
import { http, HttpResponse } from "msw";

test("handles API error gracefully", async () => {
  server.use(
    http.get("/api/users/:id", () => {
      return HttpResponse.json({ message: "Not found" }, { status: 404 });
    }),
  );

  await expect(fetchUser("999")).rejects.toThrow("Not found");
});
```

---

## Shared Test Helpers

### Database Helper

```typescript
// test/helpers/dbHelper.ts

export async function truncateTables(pool: Pool, tables: string[]) {
  for (const table of tables) {
    await pool.query(`TRUNCATE TABLE ${table} CASCADE`);
  }
}

export async function seedData(pool: Pool, table: string, rows: Record<string, unknown>[]) {
  for (const row of rows) {
    const keys = Object.keys(row);
    const values = Object.values(row);
    const placeholders = keys.map((_, i) => `$${i + 1}`).join(", ");
    await pool.query(
      `INSERT INTO ${table} (${keys.join(", ")}) VALUES (${placeholders})`,
      values,
    );
  }
}
```

Keep table and column names fixed and test-owned in helpers like these. Do not pass untrusted identifiers into interpolated SQL.

### Custom Matchers

```typescript
// test/helpers/matchers.ts
import { expect } from "vitest";

expect.extend({
  toBeWithinRange(received: number, floor: number, ceiling: number) {
    const pass = received >= floor && received <= ceiling;
    return {
      pass,
      message: () =>
        `expected ${received} to be within range ${floor} - ${ceiling}`,
    };
  },
});
```

---

## Vitest Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Global setup file
    setupFiles: ["./test/setup.ts"],

    // Optional: reset mocks between tests
    mockReset: true,

    // Test file patterns
    include: ["src/**/*.test.ts", "__tests__/**/*.test.ts"],

    // Coverage
    coverage: {
      provider: "v8",
      include: ["src/**/*.ts"],
      exclude: ["src/**/*.test.ts", "src/**/*.d.ts"],
    },
  },
});
```

---

## Integration Test Separation

### By Directory

```
src/                            # Unit tests co-located
__tests__/integration/          # Integration tests separate
```

### By File Pattern

```typescript
// vitest.config.ts — separate test projects
export default defineConfig({
  test: {
    // Default: unit tests
    include: ["src/**/*.test.ts"],
    exclude: ["**/*.integration.test.ts"],
  },
});

// vitest.integration.config.ts — integration tests
export default defineConfig({
  test: {
    include: ["**/*.integration.test.ts"],
    setupFiles: ["./test/integration-setup.ts"],
  },
});
```

```bash
# Run unit tests (fast)
vitest run

# Run integration tests
vitest run --config vitest.integration.config.ts
```

### By Vitest Projects (Workspace)

```typescript
// vitest.workspace.ts
export default [
  { test: { name: "unit", include: ["src/**/*.test.ts"] } },
  {
    test: {
      name: "integration",
      include: ["__tests__/integration/**/*.test.ts"],
      setupFiles: ["./test/integration-setup.ts"],
    },
  },
];
```

---

## When NOT to Create Shared Helpers

- Helper is used in only one test file — define it locally
- Helper hides important test logic — keep it visible in the test
- Helper adds indirection without reducing duplication — skip it
- A plain object literal is clearer than `createWidget()` for trivial objects
- Over-abstracting MSW handlers makes it hard to see what each test actually mocks

---

## Related Skills

- `typescript-testing-patterns` - Vitest, mocking, parameterized test patterns
- `typescript-test-engineer` - Comprehensive test review and coverage analysis
