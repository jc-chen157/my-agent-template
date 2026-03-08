# Go Test Fixtures Skill

Organize reusable test helpers, fixtures, and shared setup in Go projects.

## When to Use
- Tests in the same package share common setup logic
- Multiple packages need the same test infrastructure (e.g., database, containers)
- User says "refactor test setup" / "reduce test boilerplate" / "share test helpers"
- Setting up integration test infrastructure

---

## Fixture Organization Strategy

```
project/
├── internal/
│   ├── order/
│   │   ├── service.go
│   │   ├── service_test.go
│   │   └── testutil_test.go        # Package-level test helpers (test-only, _test.go)
│   ├── user/
│   │   ├── handler.go
│   │   ├── handler_test.go
│   │   └── testutil_test.go        # Package-level test helpers
│   └── ...
├── internal/testutil/               # Preferred for module-local shared test helpers
│   ├── db.go                        # Shared DB setup (dockertest, testcontainers)
│   ├── fixtures.go                  # Shared fixture builders
│   ├── assertions.go                # Custom assertion helpers
│   └── http.go                      # HTTP test helpers
├── testutil/                        # Optional when tests across module boundaries need it
│   └── ...
└── ...
```

### Decision Tree

```
Do multiple tests in THIS package share the same setup?
  ├── YES → Create testutil_test.go in the same package
  │         (file ends in _test.go so it's test-only)
  └── NO  → Inline the setup

Do multiple PACKAGES share the same setup?
  ├── YES → Create internal/testutil/ first
  │         (use top-level testutil/ only if broader sharing is required)
  └── NO  → Keep it in the package-level testutil_test.go
```

---

## Package-Level Test Helpers (testutil_test.go)

Use `_test.go` suffix so helpers are only compiled during tests and don't leak into production.

Each helper should return a **fresh value per call**. Avoid storing mutable fixture pointers in the table definition or reusing them across subtests.

```go
// internal/order/testutil_test.go
package order

import (
	"testing"
	"time"
)

// newTestOrder creates an Order with sensible defaults for testing.
// Override fields as needed in individual tests.
func newTestOrder(t *testing.T, opts ...func(*Order)) *Order {
	t.Helper()

	o := &Order{
		ID:        "test-order-1",
		UserID:    "test-user-1",
		Status:    StatusPending,
		Items:     []Item{{SKU: "ITEM-1", Qty: 1, Price: 10.00}},
		CreatedAt: time.Date(2025, 1, 1, 0, 0, 0, 0, time.UTC),
	}

	for _, opt := range opts {
		opt(o)
	}

	return o
}

// withItems overrides the order items.
func withItems(items ...Item) func(*Order) {
	return func(o *Order) {
		o.Items = items
	}
}

// withStatus overrides the order status.
func withStatus(status Status) func(*Order) {
	return func(o *Order) {
		o.Status = status
	}
}

// setupTestService creates an OrderService with mock dependencies.
// Returns the service and mocks for assertion.
func setupTestService(t *testing.T) (*Service, *mocks.MockOrderRepository, *mocks.MockNotifier) {
	t.Helper()

	repo := mocks.NewMockOrderRepository(t)
	notifier := mocks.NewMockNotifier(t)
	svc := NewService(repo, notifier)

	return svc, repo, notifier
}
```

### Usage in Tests

```go
// internal/order/service_test.go
package order

func TestService_PlaceOrder(t *testing.T) {
	tests := []struct {
		name       string
		buildOrder func(t *testing.T) *Order
		setupMocks func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier)
		wantErr    bool
	}{
		{
			name: "standard order succeeds",
			buildOrder: func(t *testing.T) *Order {
				return newTestOrder(t)
			},
			setupMocks: func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier) {
				repo.EXPECT().Save(mock.Anything, mock.Anything).Return(nil)
				notifier.EXPECT().Send(mock.Anything, mock.Anything, mock.Anything).Return(nil)
			},
		},
		{
			name: "bulk order with multiple items",
			buildOrder: func(t *testing.T) *Order {
				return newTestOrder(t, withItems(
					Item{SKU: "A", Qty: 10, Price: 5.00},
					Item{SKU: "B", Qty: 20, Price: 3.00},
				))
			},
			setupMocks: func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier) {
				repo.EXPECT().Save(mock.Anything, mock.Anything).Return(nil)
				notifier.EXPECT().Send(mock.Anything, mock.Anything, mock.Anything).Return(nil)
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			svc, repo, notifier := setupTestService(t)
			order := tt.buildOrder(t)
			tt.setupMocks(repo, notifier)

			err := svc.PlaceOrder(context.Background(), order)
			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
		})
	}
}
```

---

## Cross-Package Shared Helpers (`internal/testutil/` or `testutil/`)

For infrastructure shared across packages: database containers, HTTP helpers, common fixtures.

### Database Container Helper

```go
// testutil/db.go
package testutil

import (
	"context"
	"database/sql"
	"fmt"
	"testing"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/modules/postgres"
	"github.com/testcontainers/testcontainers-go/wait"
)

// TestDB holds a test database connection and cleanup function.
type TestDB struct {
	DB        *sql.DB
	ConnStr   string
	container testcontainers.Container
}

// NewTestDB spins up a Postgres container for integration tests.
// The container is automatically cleaned up when the test finishes.
func NewTestDB(t *testing.T) *TestDB {
	t.Helper()

	ctx := context.Background()

	pgContainer, err := postgres.Run(ctx,
		"postgres:16-alpine",
		postgres.WithDatabase("testdb"),
		postgres.WithUsername("test"),
		postgres.WithPassword("test"),
		testcontainers.WithWaitStrategy(
			wait.ForLog("database system is ready to accept connections").
				WithOccurrence(2)),
	)
	if err != nil {
		t.Fatalf("failed to start postgres container: %v", err)
	}

	connStr, err := pgContainer.ConnectionString(ctx, "sslmode=disable")
	if err != nil {
		t.Fatalf("failed to get connection string: %v", err)
	}

	db, err := sql.Open("pgx", connStr)
	if err != nil {
		t.Fatalf("failed to connect to test db: %v", err)
	}

	t.Cleanup(func() {
		db.Close()
		pgContainer.Terminate(ctx)
	})

	return &TestDB{
		DB:      db,
		ConnStr: connStr,
	}
}

// RunMigrations applies migrations to the test database.
func (tdb *TestDB) RunMigrations(t *testing.T, migrationsPath string) {
	t.Helper()
	// Apply migrations using your migration tool (goose, golang-migrate, etc.)
}

// Truncate clears all data from the given tables (for test isolation).
// Keep the table list fixed and test-owned; never pass untrusted input here.
func (tdb *TestDB) Truncate(t *testing.T, tables ...string) {
	t.Helper()
	for _, table := range tables {
		_, err := tdb.DB.Exec(fmt.Sprintf("TRUNCATE TABLE %s CASCADE", table))
		if err != nil {
			t.Fatalf("failed to truncate %s: %v", table, err)
		}
	}
}
```

### HTTP Test Helper

```go
// testutil/http.go
package testutil

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// DoRequest is a helper to make HTTP requests against a test handler.
func DoRequest(t *testing.T, handler http.Handler, method, path, body string) *httptest.ResponseRecorder {
	t.Helper()

	var bodyReader io.Reader
	if body != "" {
		bodyReader = strings.NewReader(body)
	}

	req := httptest.NewRequest(method, path, bodyReader)
	req.Header.Set("Content-Type", "application/json")

	rec := httptest.NewRecorder()
	handler.ServeHTTP(rec, req)

	return rec
}

// ParseJSON unmarshals the response body into the given target.
func ParseJSON(t *testing.T, rec *httptest.ResponseRecorder, target any) {
	t.Helper()
	err := json.NewDecoder(rec.Body).Decode(target)
	require.NoError(t, err, "failed to parse response JSON")
}

// AssertStatus asserts the response status code.
func AssertStatus(t *testing.T, rec *httptest.ResponseRecorder, want int) {
	t.Helper()
	require.Equal(t, want, rec.Code, "unexpected status code; body: %s", rec.Body.String())
}
```

### Fixture Builders

```go
// testutil/fixtures.go
package testutil

import "time"

// UserFixture builds a User with sensible defaults.
func UserFixture(opts ...func(*User)) *User {
	u := &User{
		ID:        "test-user-1",
		Email:     "test@example.com",
		Name:      "Test User",
		CreatedAt: time.Date(2025, 1, 1, 0, 0, 0, 0, time.UTC),
	}
	for _, opt := range opts {
		opt(u)
	}
	return u
}

func WithEmail(email string) func(*User) {
	return func(u *User) { u.Email = email }
}

func WithName(name string) func(*User) {
	return func(u *User) { u.Name = name }
}
```

---

## Key Patterns

### Always Use t.Helper()

Mark helper functions with `t.Helper()` so test failure messages point to the calling test, not the helper.

```go
// ❌ BAD: failure points to this line, not the test
func assertValid(t *testing.T, o *Order) {
	require.NotNil(t, o) // error reported here — unhelpful
}

// ✅ GOOD: failure points to the test that called this
func assertValid(t *testing.T, o *Order) {
	t.Helper()
	require.NotNil(t, o) // error reported at the call site
}
```

### Prefer t.Cleanup() in Helpers

Prefer `t.Cleanup()` for shared setup helpers because it composes cleanly with nested helpers and still runs after `t.FailNow()`. Local `defer` is still idiomatic when cleanup is scoped to a single test body.

```go
func setupTempDir(t *testing.T) string {
	t.Helper()
	dir := t.TempDir() // auto-cleaned up
	return dir
}

func setupServer(t *testing.T) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(handler)
	t.Cleanup(srv.Close) // guaranteed cleanup
	return srv
}
```

### Functional Options for Fixtures

Use the functional options pattern for flexible, readable test fixtures.

```go
order := newTestOrder(t,
	withStatus(StatusShipped),
	withItems(Item{SKU: "X", Qty: 5, Price: 20.00}),
)
```

---

## When NOT to Create Shared Helpers

- Helper is used in only one test file → inline it
- Helper hides important test logic → keep it visible in the test
- Helper adds indirection without reducing duplication → skip it
- Over-abstracted fixtures make tests harder to read → keep it simple

---

## Related Skills

- `golang-testing-patterns` - Table-driven tests, testify, mockery patterns
- `golang-test-engineer` - Comprehensive test review and coverage analysis
