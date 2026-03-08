# Java Backend Skill

Use this skill with `backend-engineer` or `code-review-engineer` when the project is Java backend work.

## Stack Defaults

- Spring Boot
- JUnit 5
- AssertJ over JUnit native assertions
- Mockito
- Guava
- Gson
- Apache Commons
- Guice or Dagger only when justified
- jOOQ

## Implementation Guidance

- Keep Spring at the edges and business logic in plain Java services.
- Prefer constructor injection and explicit dependencies.
- Use jOOQ when SQL shape and relational correctness matter.
- Keep transaction boundaries explicit.
- Be careful about hidden framework behavior that obscures control flow.
- Use AssertJ for readable, high-signal assertions.

## Review Heuristics

- Wrong or missing transaction boundaries
- SQL or jOOQ misuse
- Over-mocking and brittle tests
- Accidental mixing of Spring DI with Guice or Dagger
- Utility-library sprawl instead of clear domain modeling
- Poor error context and weak observability
