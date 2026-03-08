# Java Testing Patterns Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `java-backend` when reviewing or writing Java tests.

## Preferred Stack

- JUnit 5
- AssertJ
- Mockito

## Guidance

- Prefer AssertJ over JUnit native assertions for readable, high-signal checks.
- Prefer narrow unit tests for business logic and integration tests for boundaries such as Spring, DB, or messaging.
- Mock collaborators, not value objects or framework internals.
- Prefer parameterized tests when they make behavior clearer.
- Use Spring test slices or full context only when the framework wiring itself is under test.
- Prefer Testcontainers for realistic database integration when DB behavior matters.

## Review Heuristics

- Over-mocked tests with brittle interaction assertions
- Full Spring context used for logic that could be tested without it
- Weak assertions that check only non-null or status code
- Tests coupled to private methods or framework internals
- Missing transaction, retry, and error-path coverage
