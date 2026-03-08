# TypeScript Testing Patterns Skill

Vitest, mocking, and idiomatic TypeScript testing patterns.

## When to Use
- Writing unit or integration tests in TypeScript
- Setting up mocks with Vitest or Jest
- Structuring parameterized test cases
- User says "write tests" / "add tests" / "test this function"

---

## Framework Stack

| Tool | Purpose |
|------|---------|
| Vitest | Test framework — fast, native ESM + TypeScript, Vite-powered |
| `vi.mock` / `vi.fn` / `vi.spyOn` | Built-in mocking |
| `vitest-mock-extended` (optional) | Type-safe interface mocking |
| MSW (Mock Service Worker) | HTTP request interception at network level |
| v8 coverage | Built-in coverage (default in Vitest) |

Vitest is preferred for new projects. Jest is still appropriate for React Native or stable legacy codebases. The APIs are ~95% compatible.

---

## Parameterized Tests

### test.each with Objects (Preferred)

```typescript
test.each([
  { input: "user@example.com", expected: true, name: "valid email" },
  { input: "missing-at-sign", expected: false, name: "no @ symbol" },
  { input: "", expected: false, name: "empty string" },
  { input: "no-domain@", expected: false, name: "missing domain" },
])("isValidEmail: $name", ({ input, expected }) => {
  expect(isValidEmail(input)).toBe(expected);
});
```

### test.each with Arrays

```typescript
test.each([
  [1, 2, 3],
  [0, 0, 0],
  [-1, 1, 0],
])("add(%i, %i) = %i", (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});
```

### describe.each for Grouped Tests

```typescript
describe.each([
  { role: "admin", canDelete: true, canEdit: true },
  { role: "editor", canDelete: false, canEdit: true },
  { role: "viewer", canDelete: false, canEdit: false },
])("permissions for $role", ({ role, canDelete, canEdit }) => {
  let user: User;

  beforeEach(() => {
    user = createUser({ role });
  });

  test(`can${canDelete ? "" : "not"} delete`, () => {
    expect(user.canDelete()).toBe(canDelete);
  });

  test(`can${canEdit ? "" : "not"} edit`, () => {
    expect(user.canEdit()).toBe(canEdit);
  });
});
```

---

## Mocking

### Module Mocking (vi.mock)

`vi.mock` is hoisted to the top of the file — it runs before imports.

```typescript
import { fetchUser } from "./api";
import { UserService } from "./userService";

vi.mock("./api", () => ({
  fetchUser: vi.fn(),
}));

const mockedFetchUser = vi.mocked(fetchUser);

test("returns user from API", async () => {
  mockedFetchUser.mockResolvedValue({ id: 1, name: "Alice" });

  const service = new UserService();
  const user = await service.getUser(1);

  expect(user.name).toBe("Alice");
  expect(mockedFetchUser).toHaveBeenCalledWith(1);
});
```

### Per-Test Mock Control with vi.hoisted

```typescript
const { mockSave, mockNotify } = vi.hoisted(() => ({
  mockSave: vi.fn(),
  mockNotify: vi.fn(),
}));

vi.mock("./orderRepo", () => ({ save: mockSave }));
vi.mock("./notifier", () => ({ notify: mockNotify }));

beforeEach(() => {
  mockSave.mockReset();
  mockNotify.mockReset();
});

test("saves and notifies on order", async () => {
  mockSave.mockResolvedValue({ id: "123", status: "confirmed" });
  mockNotify.mockResolvedValue(undefined);

  const result = await placeOrder({ items: [{ sku: "A", qty: 2 }] });

  expect(result.status).toBe("confirmed");
  expect(mockSave).toHaveBeenCalledOnce();
  expect(mockNotify).toHaveBeenCalledWith("order_placed", expect.any(Object));
});

test("still confirms when notification fails", async () => {
  mockSave.mockResolvedValue({ id: "456", status: "confirmed" });
  mockNotify.mockRejectedValue(new Error("notification down"));

  const result = await placeOrder({ items: [{ sku: "B", qty: 1 }] });

  expect(result.status).toBe("confirmed");
});
```

### Function Mocking (vi.fn)

```typescript
test("calls callback with result", () => {
  const callback = vi.fn();

  processItems([1, 2, 3], callback);

  expect(callback).toHaveBeenCalledTimes(3);
  expect(callback).toHaveBeenCalledWith(1);
  expect(callback).toHaveBeenLastCalledWith(3);
});
```

### Spy (vi.spyOn)

Observe calls without replacing implementation (unless configured).

```typescript
test("logs before processing", () => {
  const spy = vi.spyOn(console, "log").mockImplementation(() => {});

  processOrder(order);

  expect(spy).toHaveBeenCalledWith("Processing order:", order.id);
  spy.mockRestore();
});
```

### Type-Safe Mocking with vitest-mock-extended

```typescript
import { mock, mockDeep } from "vitest-mock-extended";

interface OrderRepository {
  save(order: Order): Promise<Order>;
  findById(id: string): Promise<Order | null>;
}

test("places order", async () => {
  const mockRepo = mock<OrderRepository>();
  mockRepo.save.mockResolvedValue({ id: "1", status: "confirmed" } as Order);

  const service = new OrderService(mockRepo);
  const result = await service.placeOrder(sampleOrder());

  expect(result.status).toBe("confirmed");
  expect(mockRepo.save).toHaveBeenCalledWith(expect.objectContaining({ status: "pending" }));
});
```

### MSW for HTTP Mocking

Mock at the network level — works across unit and integration tests.

```typescript
import { setupServer } from "msw/node";
import { http, HttpResponse } from "msw";

const server = setupServer(
  http.get("/api/users/:id", ({ params }) => {
    return HttpResponse.json({ id: params.id, name: "Alice" });
  }),
  http.post("/api/orders", async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: "123", ...body }, { status: 201 });
  }),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test("fetches user from API", async () => {
  const user = await fetchUser("1");
  expect(user.name).toBe("Alice");
});

// Override for a specific test
test("handles API error", async () => {
  server.use(
    http.get("/api/users/:id", () => {
      return HttpResponse.json({ message: "Not found" }, { status: 404 });
    }),
  );

  await expect(fetchUser("999")).rejects.toThrow("Not found");
});
```

---

## Assertions

### Common Patterns

```typescript
// Equality
expect(result).toBe(expected);           // strict ===
expect(result).toEqual(expected);         // deep equality
expect(result).toStrictEqual(expected);   // deep + no extra properties

// Truthiness
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();

// Numbers
expect(value).toBeGreaterThan(3);
expect(value).toBeLessThanOrEqual(10);
expect(value).toBeCloseTo(3.14, 2);      // 2 decimal places

// Strings
expect(result).toContain("expected");
expect(result).toMatch(/pattern/);

// Arrays / Objects
expect(array).toHaveLength(3);
expect(array).toContain(element);
expect(array).toContainEqual({ id: 1 });
expect(object).toHaveProperty("name", "Alice");
expect(result).toMatchObject({ status: "confirmed" });

// Partial matching
expect(fn).toHaveBeenCalledWith(
  expect.objectContaining({ id: "123" }),
  expect.any(String),
);
```

### Error Testing

```typescript
// Sync
expect(() => processPayment(-1)).toThrow("must be positive");
expect(() => processPayment(-1)).toThrow(PaymentError);

// Async
await expect(fetchUser("invalid")).rejects.toThrow("not found");
await expect(fetchUser("1")).resolves.toEqual({ id: "1", name: "Alice" });
```

### Snapshot Testing

```typescript
test("renders correctly", () => {
  const result = renderReport(sampleData);
  expect(result).toMatchSnapshot();
});

// Inline snapshot (stored in the test file)
test("formats address", () => {
  expect(formatAddress(address)).toMatchInlineSnapshot(`
    "123 Main St
    Springfield, IL 62701"
  `);
});
```

---

## Test Structure & Lifecycle

### File Organization

```
src/
├── services/
│   ├── orderService.ts
│   └── orderService.test.ts    # Co-located (preferred)
├── utils/
│   ├── validation.ts
│   └── validation.test.ts
├── __tests__/                   # Alternative: dedicated directory
│   └── integration/
│       └── orderApi.test.ts
└── test/
    └── helpers/                 # Shared test utilities
        ├── fixtures.ts
        └── setup.ts
```

### Lifecycle Hooks

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
    mockRepo.save.mockResolvedValue(confirmedOrder);
    const result = await service.placeOrder(pendingOrder);
    expect(result.status).toBe("confirmed");
  });
});
```

### Global Setup

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    setupFiles: ["./test/setup.ts"],
    mockReset: true,  // Optional: auto-reset mocks between tests
  },
});

// test/setup.ts
import { afterAll, afterEach, beforeAll } from "vitest";
import { server } from "./mocks/server";

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## Async Testing

### async/await (Preferred)

```typescript
test("fetches user", async () => {
  const user = await userService.getUser("1");
  expect(user.name).toBe("Alice");
});
```

### Timer Mocking

```typescript
test("debounces search", async () => {
  vi.useFakeTimers();

  const callback = vi.fn();
  const debouncedSearch = debounce(callback, 300);

  debouncedSearch("query");
  expect(callback).not.toHaveBeenCalled();

  vi.advanceTimersByTime(300);
  expect(callback).toHaveBeenCalledWith("query");

  vi.useRealTimers();
});
```

### Promise Assertions

```typescript
// Always await async assertions — Vitest 3+ warns, 4+ fails if you don't
await expect(fetchUser("1")).resolves.toEqual({ id: "1", name: "Alice" });
await expect(failingFetch()).rejects.toThrow("Network error");
```

---

## TypeScript-Specific Patterns

### Testing Type Guards

```typescript
function isUser(value: unknown): value is User {
  return typeof value === "object" && value !== null && "name" in value;
}

test("identifies valid user objects", () => {
  expect(isUser({ name: "Alice", email: "a@b.com" })).toBe(true);
  expect(isUser({ email: "a@b.com" })).toBe(false);
  expect(isUser(null)).toBe(false);
  expect(isUser("string")).toBe(false);
});
```

### Testing with @ts-expect-error

Document that certain calls should be type errors.

```typescript
test("rejects invalid arguments at compile time", () => {
  // @ts-expect-error — string is not assignable to number
  processPayment("not a number");
});
```

### Dependency Injection for Testability

```typescript
// ❌ Hard to test — tightly coupled
class OrderService {
  private repo = new PostgresOrderRepo();  // FLAGGED
}

// ✅ Testable — dependency injected
class OrderService {
  constructor(private repo: OrderRepository) {}
}

// In tests
const mockRepo = mock<OrderRepository>();
const service = new OrderService(mockRepo);
```

---

## Integration & E2E Testing

### API Testing with Supertest

```typescript
import request from "supertest";
import app from "./app";

describe("GET /api/users/:id", () => {
  test("returns user", async () => {
    const res = await request(app)
      .get("/api/users/1")
      .expect(200)
      .expect("Content-Type", /json/);

    expect(res.body).toMatchObject({ id: "1", name: "Alice" });
  });

  test("returns 404 for missing user", async () => {
    await request(app)
      .get("/api/users/nonexistent")
      .expect(404);
  });
});
```

### Testcontainers

```typescript
import { PostgreSqlContainer } from "@testcontainers/postgresql";

describe("UserRepository", () => {
  let container: StartedPostgreSqlContainer;
  let repo: UserRepository;

  beforeAll(async () => {
    container = await new PostgreSqlContainer().start();
    const pool = new Pool({ connectionString: container.getConnectionUri() });
    repo = new UserRepository(pool);
  }, 30_000);

  afterAll(async () => {
    await container.stop();
  });

  beforeEach(async () => {
    await repo.deleteAll(); // Clean state per test
  });

  test("saves and retrieves user", async () => {
    const saved = await repo.save({ name: "Alice", email: "alice@test.com" });
    const found = await repo.findById(saved.id);
    expect(found).toMatchObject({ name: "Alice" });
  });
});
```

### E2E with Playwright

Playwright is preferred for E2E testing (multi-browser, faster, native parallelism). Cypress is an alternative when team developer experience is prioritized.

---

## Coverage

### Configuration

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: "v8",
      reporter: ["text", "html", "json"],
      include: ["src/**/*.ts"],
      exclude: ["src/**/*.test.ts", "src/**/*.d.ts"],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80,
      },
    },
  },
});
```

```bash
# Run with coverage
vitest run --coverage

# Watch mode with coverage
vitest --coverage
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Do Instead |
|--------------|---------|------------|
| Testing implementation details | Brittle, breaks on refactor | Test behavior and outputs |
| Over-mocking | Tests pass but real code fails | Mock only external boundaries |
| Shared mutable state between tests | Order-dependent, flaky | Fresh state in `beforeEach` |
| Not awaiting async assertions | Silent failures (Vitest 3+ warns) | Always `await expect(...).resolves` |
| `vi.mock` without a reset / restore strategy | Stale mock state leaks | Reset via config or explicit hooks such as `beforeEach` / `vi.restoreAllMocks()` |
| Testing private methods | Coupled to implementation | Test via public API |
| Global test timeout increase | Masks slow tests | Fix the slow test, mock the slow dependency, or set timeout per-test |
| Hard-wired dependencies where a seam is needed | Harder to substitute in narrow tests | Use constructor injection or module-boundary mocking |
| No `expect.assertions(n)` in callback-heavy async tests | Missing assertions can go unnoticed | Use `expect.assertions()` or `expect.hasAssertions()` selectively |

---

## Related Skills

- `typescript-test-fixtures` — Fixture organization and shared setup patterns
- `typescript-test-engineer` — Comprehensive test review and coverage analysis
