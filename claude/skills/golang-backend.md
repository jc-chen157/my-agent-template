# Golang Backend Skill

Use this skill with `backend-engineer` or `code-review-engineer` when the project is Go backend work.

## Stack Defaults

- Gin
- SQLite
- testify
- mockery

## Implementation Guidance

- Write idiomatic Go first and treat frameworks as transport helpers.
- Keep handlers thin.
- Pass `context.Context` through request and dependency boundaries.
- Be deliberate with goroutines, channels, mutexes, and shutdown.
- Use SQLite honestly with awareness of write concurrency limits.
- Use mocks only for narrow interfaces you actually own.

## Review Heuristics

- Misuse of `context.Context`
- Goroutine leaks and deadlocks
- Bloated interfaces and abstraction overkill
- Gin handlers doing too much
- SQLite locking or transaction mistakes
- Mock-heavy tests that signal weak design
