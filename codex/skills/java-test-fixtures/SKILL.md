---
name: java-test-fixtures
description: Use this skill for Java test fixture design and shared setup. It provides guidance for fixture builders, local versus shared setup, Spring test boundaries, and deterministic integration fixtures.
---

# Java Test Fixtures

Use this skill when Java tests need better setup and fixture structure.

Guidance:

- Prefer focused fixture builders and test data factories over giant object mother classes.
- Keep unit-test setup local unless reuse is real and repeated.
- Use constructor-based test setup so dependencies stay visible.
- Keep Spring context usage narrow.
- Prefer Testcontainers or explicit integration fixtures for real boundary tests.
- Make database cleanup and seed behavior deterministic.

Review heuristics:

- overgrown base test classes
- hidden fixture setup that masks dependencies
- Spring-heavy tests for plain business logic
- shared mutable static fixtures
- builders with too many defaults that obscure the scenario
