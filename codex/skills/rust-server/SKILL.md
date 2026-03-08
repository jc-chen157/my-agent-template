---
name: rust-server
description: Use this skill for Rust backend work and Rust backend code review. It provides stack-specific guidance for Tokio, Axum, Tower, tracing, and relational persistence libraries such as SQLx or Diesel.
---

# Rust Server

Use these defaults:

- Tokio
- Axum
- Tower
- tracing
- SQLx or Diesel

Guidance:

- Use the type system to encode invariants when it materially improves safety.
- Keep async boundaries explicit.
- Do not hold locks across `.await`.
- Avoid blocking executor threads.
- Prefer bounded concurrency and owner-task patterns over tangled shared state.
- Keep shutdown, retries, and observability intentional.

Review heuristics:

- Lock guards across `.await`
- Hidden blocking on async executors
- Unbounded task fan-out
- Unclear ownership or unnecessary cloning
- Weak shutdown behavior
- Missing backpressure or poor error context
