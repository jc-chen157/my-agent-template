# TypeScript Testing Patterns Skill

Use this skill with `reviewer-test-quality`, `frontend-engineer`, or `node-nextjs-backend` when reviewing or writing TypeScript tests.

## Preferred Stack

- Vitest by default

## Guidance

- Prefer behavior-focused assertions over implementation-detail checks.
- Use parameterized tests where behavior matrices exist.
- Keep module mocking narrow and reset mock state cleanly.
- Prefer network-level mocking for HTTP boundaries when appropriate.
- Be explicit about async expectations and always await async assertions.
- Use typed helpers to keep fixtures and expectations honest.

## Review Heuristics

- Snapshot overuse with weak behavioral assertions
- Mock-heavy tests that lock in internals
- Async assertions that are not awaited
- Tests tightly coupled to hook/component/private-function internals
- Missing coverage for error states, retries, or stale data behavior
