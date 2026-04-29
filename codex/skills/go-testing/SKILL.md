---
name: go-testing
description: Use this skill for Go tests, test review, and fixture or shared setup design. It covers table-driven tests, testify, mockery, httptest, deterministic concurrency and error-path testing, t.Helper, t.TempDir, and isolated readable fixtures.
---

# Go Testing

Use this skill when writing, reviewing, or reshaping Go tests.

Testing guidance:

- Prefer table-driven tests for behavior with multiple input/output cases.
- Use `require` for setup-critical assertions and `assert` for follow-on checks.
- Test behavior and outcomes, not private implementation details.
- Keep concurrency tests deterministic with explicit synchronization and time control.
- Prefer `httptest` for handler and API tests.
- Inject clocks, randomness, and external dependencies instead of hard-wiring them.

Fixture guidance:

- Prefer small factory helpers over giant shared fixture packages.
- Keep table inputs close to the test unless the data is reused meaningfully.
- Use `t.Helper()` in helper functions.
- Prefer explicit constructors for test subjects over hidden global setup.
- Use `t.TempDir()` and per-test state to avoid cross-test contamination.
- Prefer narrow request helpers for HTTP tests.

Review heuristics:

- nondeterministic time- or goroutine-based tests
- overuse of mocks instead of simple fakes or direct state assertions
- cryptic table-driven test cases
- shared mutable fixture state
- hidden setup that obscures the scenario
- missing cancellation, timeout, and error-path coverage
