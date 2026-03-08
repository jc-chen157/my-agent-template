---
name: java-testing-patterns
description: Use this skill for Java testing patterns. It provides guidance for JUnit 5, AssertJ, Mockito, Spring test slices, and realistic integration testing boundaries.
---

# Java Testing Patterns

Use this skill when reviewing or writing Java tests.

Guidance:

- Prefer AssertJ over JUnit native assertions for readable, high-signal checks.
- Prefer narrow unit tests for business logic and integration tests for boundaries such as Spring, DB, or messaging.
- Mock collaborators, not value objects or framework internals.
- Prefer parameterized tests when they make behavior clearer.
- Use Spring test slices or full context only when framework wiring itself is under test.
- Prefer Testcontainers for realistic database integration when DB behavior matters.

Review heuristics:

- over-mocked tests with brittle interaction assertions
- full Spring context used for logic that could be tested without it
- weak assertions that check only non-null or status code
- tests coupled to private methods or framework internals
- missing transaction, retry, and error-path coverage
