# Java Test Fixtures Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `java-backend` when Java tests need better fixture organization or reusable setup.

## Guidance

- Prefer focused fixture builders and test data factories over giant object mother classes.
- Keep unit-test setup local unless reuse is real and repeated.
- Use constructor-based test setup so dependencies stay visible.
- Keep Spring context usage narrow; do not pay for full application startup in tests that do not need it.
- Prefer Testcontainers or explicit integration fixtures for real boundary tests.
- Make database cleanup and seed behavior deterministic.

## Review Heuristics

- Overgrown base test classes
- Hidden fixture setup that masks dependencies
- Spring-heavy tests for plain business logic
- Shared mutable static fixtures
- Builders with too many defaults that obscure the scenario
