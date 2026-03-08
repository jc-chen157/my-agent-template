---
name: golang-testing-patterns
description: Use this skill for Go testing patterns. It provides guidance for table-driven tests, testify, mockery, `httptest`, and deterministic concurrency and error-path testing in Go.
---

# Golang Testing Patterns

Use this skill when reviewing or writing Go tests.

Guidance:

- Prefer table-driven tests for behavior with multiple input/output cases.
- Use `require` for setup-critical assertions and `assert` for follow-on checks.
- Test behavior and outcomes, not internal implementation details.
- Keep concurrency tests deterministic with explicit synchronization and time control.
- Prefer `httptest` for handler and API tests.
- Inject clocks, randomness, and external dependencies rather than hard-wiring them.

Review heuristics:

- overuse of mocks instead of simple fakes or direct state assertions
- nondeterministic time- or goroutine-based tests
- cryptic table-driven test cases
- tests coupled to private implementation details
- missing cancellation, timeout, and error-path coverage
