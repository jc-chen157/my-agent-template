---
name: java-backend
description: Use this skill for Java backend work and Java backend code review. It provides stack-specific guidance for Spring Boot, JUnit 5, AssertJ, Mockito, Guava, Gson, Apache Commons, Guice or Dagger, and jOOQ.
---

# Java Backend

Use these defaults:

- Spring Boot
- JUnit 5
- AssertJ over JUnit native assertions
- Mockito
- Guava
- Gson
- Apache Commons
- Guice or Dagger only when justified
- jOOQ

Guidance:

- Keep Spring at the edges and business logic in plain Java services.
- Prefer constructor injection and explicit dependencies.
- Keep transaction boundaries explicit.
- Use jOOQ when SQL shape and relational correctness matter.
- Be careful about hidden framework behavior.
- Use AssertJ for readable, high-signal assertions.

Review heuristics:

- Wrong or missing transaction boundaries
- SQL or jOOQ misuse
- Over-mocking and brittle tests
- Accidental mixing of Spring DI with Guice or Dagger
- Utility-library sprawl instead of clear domain modeling
- Poor error context and weak observability
