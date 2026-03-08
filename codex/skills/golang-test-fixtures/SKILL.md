---
name: golang-test-fixtures
description: Use this skill for Go test fixture design and shared setup. It provides guidance on helper scope, `t.Helper()`, `t.TempDir()`, fixture visibility, and keeping Go tests isolated and readable.
---

# Golang Test Fixtures

Use this skill when Go tests need better setup and fixture structure.

Guidance:

- Prefer small factory helpers over giant shared fixture packages.
- Keep table-driven inputs close to the test unless the data is reused meaningfully.
- Use `t.Helper()` in helper functions.
- Prefer explicit constructors for test subjects over hidden global setup.
- Use `t.TempDir()` and per-test state to avoid cross-test contamination.
- Prefer `httptest` and narrow request helpers for HTTP tests.

Review heuristics:

- shared mutable fixture state
- hidden setup that obscures the scenario
- helpers that do too much implicitly
- global temp paths, ports, or clock state
- mock-heavy fixtures that reduce readability
