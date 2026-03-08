---
name: go-backend
description: Use this skill for Go backend work and Go backend code review. It provides stack-specific guidance for Gin, SQLite, testify, and mockery.
---

# Go Backend

Use these defaults:

- Gin
- SQLite
- testify
- mockery

Guidance:

- Write idiomatic Go first and treat frameworks as transport helpers.
- Keep handlers thin.
- Pass `context.Context` through request and dependency boundaries.
- Be deliberate with goroutines, channels, mutexes, and shutdown.
- Use SQLite honestly with awareness of write concurrency limits.
- Use mocks only for narrow interfaces you actually own.

Review heuristics:

- Misuse of `context.Context`
- Goroutine leaks and deadlocks
- Bloated interfaces and abstraction overkill
- Gin handlers doing too much
- SQLite locking or transaction mistakes
- Mock-heavy tests that signal weak design
