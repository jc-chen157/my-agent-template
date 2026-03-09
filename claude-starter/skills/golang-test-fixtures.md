# Golang Test Fixtures Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `golang-backend` when Go tests need shared setup, helper design, or fixture cleanup.

## Guidance

- Prefer small factory helpers over giant shared fixture packages.
- Keep table-driven inputs close to the test unless the data is reused meaningfully.
- Use `t.Helper()` in helper functions.
- Prefer explicit constructors for test subjects over hidden global setup.
- Use `t.TempDir()` and per-test state to avoid cross-test contamination.
- For HTTP tests, prefer `httptest` servers and request helpers over broad integration harnesses.
- Keep mockery-generated mocks narrow and close to the interfaces the consumer owns.

## Review Heuristics

- Shared mutable fixture state
- Hidden setup that obscures the scenario
- Helpers that do too much work implicitly
- Global temp paths, ports, or clock state
- Mock-heavy fixtures that make the test harder to read than the production code
