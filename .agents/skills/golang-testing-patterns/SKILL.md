# Go Testing Patterns Skill

Standard library testing, optional testify assertions, and pragmatic mocking patterns for Go.

## When to Use
- Writing unit tests in Go
- Setting up mocks with mockery
- Structuring test cases with table-driven patterns
- User says "write tests" / "add unit tests" / "test this function"

---

## Framework Stack

| Tool | Purpose |
|------|---------|
| `testing` | Standard library test runner, subtests, helpers, and benchmarks |
| `testify` (optional) | `assert` / `require` helpers when the repo already uses them |
| `mockery` (optional) | Generated mocks for collaborator-heavy interfaces |
| Table-driven tests | Idiomatic way to express data-driven scenarios |

Prefer plain tests and subtests over suite abstractions. Prefer small fakes or hand-written stubs when they are simpler than generated mocks.

---

## Table-Driven Tests

### Basic Structure

```go
func TestCalculateDiscount(t *testing.T) {
	tests := []struct {
		name     string
		price    float64
		quantity int
		want     float64
		wantErr  bool
	}{
		{
			name:     "standard discount for bulk order",
			price:    100.0,
			quantity: 10,
			want:     950.0,
		},
		{
			name:     "no discount for small order",
			price:    100.0,
			quantity: 2,
			want:     200.0,
		},
		{
			name:     "zero quantity returns error",
			price:    100.0,
			quantity: 0,
			wantErr:  true,
		},
		{
			name:     "negative price returns error",
			price:    -10.0,
			quantity: 5,
			wantErr:  true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := CalculateDiscount(tt.price, tt.quantity)
			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
		})
	}
}
```

---

## Mocking Patterns

Prefer small fakes or hand-written stubs when behavior is simple. Reach for `mockery` when collaborator expectations would otherwise be repetitive or noisy.

### Per-Test Mock Setup (Preferred)

Stub mocks as part of the table structure using a `setupMocks` function. Each test case defines its own mock behavior.

```go
func TestOrderService_PlaceOrder(t *testing.T) {
	tests := []struct {
		name       string
		order      *Order
		setupMocks func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier)
		want       *OrderResult
		wantErr    string
	}{
		{
			name:  "successful order placement",
			order: &Order{ID: "123", Items: []Item{{SKU: "A", Qty: 2}}},
			setupMocks: func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier) {
				repo.EXPECT().Save(mock.Anything, mock.AnythingOfType("*Order")).
					Return(nil)
				notifier.EXPECT().Send(mock.Anything, "order_placed", mock.Anything).
					Return(nil)
			},
			want: &OrderResult{Status: "confirmed"},
		},
		{
			name:  "repository save fails",
			order: &Order{ID: "456", Items: []Item{{SKU: "B", Qty: 1}}},
			setupMocks: func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier) {
				repo.EXPECT().Save(mock.Anything, mock.AnythingOfType("*Order")).
					Return(errors.New("db connection lost"))
				// notifier should NOT be called on save failure
			},
			wantErr: "failed to save order",
		},
		{
			name:  "notification fails but order still succeeds",
			order: &Order{ID: "789", Items: []Item{{SKU: "C", Qty: 3}}},
			setupMocks: func(repo *mocks.MockOrderRepository, notifier *mocks.MockNotifier) {
				repo.EXPECT().Save(mock.Anything, mock.AnythingOfType("*Order")).
					Return(nil)
				notifier.EXPECT().Send(mock.Anything, "order_placed", mock.Anything).
					Return(errors.New("notification service down"))
			},
			want: &OrderResult{Status: "confirmed"}, // order still succeeds
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			repo := mocks.NewMockOrderRepository(t)
			notifier := mocks.NewMockNotifier(t)
			tt.setupMocks(repo, notifier)

			svc := NewOrderService(repo, notifier)
			got, err := svc.PlaceOrder(context.Background(), tt.order)

			if tt.wantErr != "" {
				require.Error(t, err)
				assert.Contains(t, err.Error(), tt.wantErr)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want.Status, got.Status)
		})
	}
}
```

### Shared Defaults Without Shared Mocks

If many cases need the same default collaborator behavior, put that setup in a helper that returns a **fresh mock per subtest**. Do not create one mutable mock outside the subtests and reuse it across cases.

```go
func newCacheReturningMiss(t *testing.T) *mocks.MockCache {
	t.Helper()

	cache := mocks.NewMockCache(t)
	cache.EXPECT().Get(mock.Anything, mock.AnythingOfType("string")).
		Return(nil, ErrCacheMiss).Maybe()
	return cache
}

func TestUserService_GetProfile(t *testing.T) {
	tests := []struct {
		name       string
		userID     string
		setupMocks func(repo *mocks.MockUserRepository)
		want       *User
		wantErr    bool
	}{
		{
			name:   "user found",
			userID: "user-1",
			setupMocks: func(repo *mocks.MockUserRepository) {
				repo.EXPECT().FindByID(mock.Anything, "user-1").
					Return(&User{ID: "user-1", Name: "Alice"}, nil)
			},
			want: &User{ID: "user-1", Name: "Alice"},
		},
		{
			name:   "user not found",
			userID: "user-999",
			setupMocks: func(repo *mocks.MockUserRepository) {
				repo.EXPECT().FindByID(mock.Anything, "user-999").
					Return(nil, ErrNotFound)
			},
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			repo := mocks.NewMockUserRepository(t)
			cache := newCacheReturningMiss(t)
			tt.setupMocks(repo)

			svc := NewUserService(repo, cache)
			got, err := svc.GetProfile(context.Background(), tt.userID)

			if tt.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
		})
	}
}
```

---

## Testify Usage

### assert vs require

| Function | On failure... | Use when |
|----------|---------------|----------|
| `assert.X` | Marks test failed, **continues** | Non-critical checks, want to see all failures |
| `require.X` | Marks test failed, **stops immediately** | Critical preconditions (nil checks, errors) |

```go
func TestExample(t *testing.T) {
	result, err := DoSomething()

	// Use require for preconditions — no point continuing if err != nil
	require.NoError(t, err)
	require.NotNil(t, result)

	// Use assert for value checks — see all failures at once
	assert.Equal(t, "expected", result.Name)
	assert.Equal(t, 42, result.Age)
	assert.True(t, result.Active)
}
```

### Common Assertions

```go
// Equality
assert.Equal(t, expected, actual)
assert.NotEqual(t, unexpected, actual)

// Nil checks
assert.Nil(t, value)
assert.NotNil(t, result)

// Boolean
assert.True(t, condition)
assert.False(t, condition)

// Error handling
assert.Error(t, err)
assert.NoError(t, err)
assert.ErrorIs(t, err, ErrNotFound)
assert.ErrorContains(t, err, "not found")

// Collections
assert.Len(t, slice, 3)
assert.Contains(t, slice, element)
assert.Empty(t, slice)
assert.ElementsMatch(t, expected, actual) // order-independent

// Approximate (floats)
assert.InDelta(t, 3.14, result, 0.01)

// JSON
assert.JSONEq(t, `{"key":"value"}`, jsonString)
```

---

## Naming Conventions

### Test Functions

```go
// Pattern: Test<Type>_<Method> or Test<Function>
func TestOrderService_PlaceOrder(t *testing.T) { }
func TestCalculateDiscount(t *testing.T) { }
```

### Test Case Names

```go
// Descriptive, lowercase, describe the scenario
tests := []struct {
	name string
}{
	{name: "returns error when user not found"},
	{name: "applies bulk discount for orders over 100"},
	{name: "handles empty input gracefully"},
	{name: "concurrent writes do not race"},
}
```

### Mock Generation

```bash
# Generate mocks with mockery
# In .mockery.yaml or per-interface:
mockery --name=OrderRepository --output=./mocks --outpkg=mocks
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Do Instead |
|--------------|---------|------------|
| One giant test function | Hard to identify failures | Table-driven with `t.Run` |
| Shared mutable state between tests | Flaky, order-dependent | Fresh mocks per `t.Run` |
| Mocking everything | Tests break on refactor | Mock only external boundaries |
| `assert` for preconditions | Test continues in broken state | Use `require` for preconditions |
| Hardcoded test data | Brittle | Constants or builder helpers |
| Testing private functions directly | Couples to implementation | Test via public API |

---

## Related Skills

- `golang-test-fixtures` - Reusable setup helpers and test_utils organization
- `golang-test-engineer` - Comprehensive test review and coverage analysis
