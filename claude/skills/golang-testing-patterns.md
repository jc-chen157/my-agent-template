# Golang Testing Patterns Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `golang-backend` when reviewing or writing Go tests.

## Preferred Stack

- `testing`
- `testify`
- `mockery`

## Guidance

- Prefer table-driven tests for behavior with multiple input/output cases.
- Use `require` for setup-critical assertions and `assert` for follow-on checks.
- Test behavior and outcomes, not internal implementation details.
- Keep concurrency tests deterministic with explicit synchronization and time control.
- Prefer `httptest` for handler and API tests.
- Inject clocks, randomness, and external dependencies rather than hard-wiring them.

## Review Heuristics

- Overuse of mocks instead of simple fakes or direct state assertions
- Nondeterministic time- or goroutine-based tests
- Table-driven tests that hide intent with cryptic field names
- Tests coupled to private implementation details
- Missing cancellation, timeout, and error-path coverage
