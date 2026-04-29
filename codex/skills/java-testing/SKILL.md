---
name: java-testing
description: Use this skill for Java tests, test review, and fixture or shared setup design. It covers JUnit 5, AssertJ, Mockito, Spring test slices, Testcontainers, fixture builders, deterministic database setup, and integration-test boundaries.
---

# Java Testing

Use this skill when writing, reviewing, or reshaping Java tests.

Testing guidance:

- Prefer AssertJ over JUnit native assertions for readable, high-signal checks.
- Prefer narrow unit tests for business logic and integration tests for Spring, database, or messaging boundaries.
- Mock collaborators, not value objects or framework internals.
- Prefer parameterized tests when they make behavior clearer.
- Use Spring test slices or full context only when framework wiring itself is under test.
- Prefer Testcontainers for realistic database integration when DB behavior matters.

Fixture guidance:

- Prefer focused fixture builders and test data factories over giant object mother classes.
- Keep unit-test setup local unless reuse is real and repeated.
- Use constructor-based test setup so dependencies stay visible.
- Keep Spring context usage narrow.
- Make database cleanup and seed behavior deterministic.

Review heuristics:

- over-mocked tests with brittle interaction assertions
- full Spring context used for plain business logic
- weak assertions that check only non-null or status code
- hidden fixture setup that masks dependencies
- overgrown base test classes
- missing transaction, retry, and error-path coverage
