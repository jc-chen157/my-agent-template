---
name: typescript-testing
description: Use this skill for TypeScript tests, test review, and fixture or shared setup design. It covers Vitest-style testing, module mocking, async assertions, parameterized tests, behavior-first structure, factory functions, mock reset boundaries, and app setup separation.
---

# TypeScript Testing

Use this skill when writing, reviewing, or reshaping TypeScript tests.

Testing guidance:

- Prefer behavior-focused assertions over implementation-detail checks.
- Use parameterized tests where behavior matrices exist.
- Keep module mocking narrow and reset mock state cleanly.
- Prefer network-level mocking for HTTP boundaries when appropriate.
- Be explicit about async expectations and always await async assertions.
- Use typed helpers to keep fixtures and expectations honest.

Fixture guidance:

- Prefer factory functions and small builders over large fixture objects reused everywhere.
- Keep test setup visible; do not bury the scenario under layers of helpers.
- Use per-test fresh objects rather than mutating shared literals.
- Centralize HTTP mocking only when multiple tests truly share the same boundary behavior.
- Separate unit-test data helpers from app/server/client setup helpers.
- Keep async setup and teardown explicit.

Review heuristics:

- snapshot overuse with weak behavioral assertions
- mock-heavy tests that lock in internals
- async assertions that are not awaited
- shared mutable fixture objects
- global mocks leaking across tests
- missing coverage for error states, retries, or stale data behavior
