# Rust Server Skill

Use this skill with `backend-engineer` or `code-review-engineer` when the project is Rust backend work.

## Stack Defaults

- Tokio
- Axum
- Tower
- tracing
- SQLx or Diesel

## Implementation Guidance

- Use the type system to encode invariants when it materially improves safety.
- Keep async boundaries explicit.
- Do not hold locks across `.await`.
- Avoid blocking executor threads.
- Prefer bounded concurrency and owner-task patterns over tangled shared state.
- Keep shutdown, retries, and observability intentional.

## Review Heuristics

- Lock guards across `.await`
- Hidden blocking on async executors
- Unbounded task fan-out
- Unclear ownership or unnecessary cloning
- Weak shutdown behavior
- Missing backpressure or poor error context
