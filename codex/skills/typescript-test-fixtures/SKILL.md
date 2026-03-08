---
name: typescript-test-fixtures
description: Use this skill for TypeScript test fixture design and shared setup. It provides guidance for factory functions, fixture visibility, mock reset boundaries, and separating data fixtures from app setup.
---

# TypeScript Test Fixtures

Use this skill when TypeScript tests need better setup and fixture structure.

Guidance:

- Prefer factory functions and small builders over large fixture objects reused everywhere.
- Keep test setup visible; do not bury the scenario under layers of helpers.
- Use per-test fresh objects rather than mutating shared literals.
- Centralize HTTP mocking only when multiple tests truly share the same boundary behavior.
- Separate unit-test data helpers from app/server/client setup helpers.
- Keep async setup and teardown explicit.

Review heuristics:

- shared mutable fixture objects
- over-abstracted helpers that obscure the scenario
- global mocks leaking across tests
- fixture defaults that accidentally encode business assumptions
- too much setup hidden in shared bootstrap
