---
name: rust-testing-patterns
description: Use this skill for Rust testing patterns. It provides guidance for `cargo test`, `#[test]`, `#[tokio::test]`, outcome-focused assertions, and async and error-path testing in Rust.
---

# Rust Testing Patterns

Use this skill when reviewing or writing Rust tests.

Guidance:

- Prefer outcome-focused tests over implementation-detail assertions.
- Use the type system in tests too; avoid loose strings or maps when strong types improve clarity.
- Keep async tests explicit about task coordination and shutdown.
- Test error variants and edge cases directly, not only happy paths.
- Use integration tests for crate boundaries and end-to-end flows when boundary behavior matters.

Review heuristics:

- async tests that can hang or depend on timing
- weak matching on error variants or state transitions
- overuse of shared helpers that hide ownership and setup
- tests that fight the borrow checker by cloning everything unnecessarily
- missing coverage for cancellation, invalid input, or partial-failure behavior
