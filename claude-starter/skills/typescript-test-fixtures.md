# TypeScript Test Fixtures Skill

Use this skill with `reviewer-test-quality`, `frontend-engineer`, or `node-nextjs-backend` when TypeScript tests need better shared setup or fixture factoring.

## Guidance

- Prefer factory functions and small builders over large fixture objects reused everywhere.
- Keep test setup visible; do not bury the scenario under layers of helpers.
- Use per-test fresh objects rather than mutating shared literals.
- Centralize HTTP mocking only when multiple tests truly share the same boundary behavior.
- Separate unit-test data helpers from app/server/client setup helpers.
- Keep async setup and teardown explicit.

## Review Heuristics

- Shared mutable fixture objects
- Over-abstracted helpers that obscure the scenario
- Global mocks leaking across tests
- Fixture defaults that accidentally encode business assumptions
- Too much setup hidden in `beforeEach` or shared test bootstrap
