---
name: rust-testing
description: Use this skill for Rust tests, test review, and fixture or shared setup design. It covers cargo test, #[test], #[tokio::test], outcome-focused assertions, async/error-path testing, builders, temporary resources, and isolated fixtures.
---

# Rust Testing

Use this skill when writing, reviewing, or reshaping Rust tests.

Testing guidance:

- Prefer outcome-focused tests over implementation-detail assertions.
- Use strong types in tests when they improve clarity.
- Keep async tests explicit about task coordination and shutdown.
- Test error variants and edge cases directly, not only happy paths.
- Use integration tests for crate boundaries and end-to-end flows when boundary behavior matters.

Fixture guidance:

- Prefer small helper constructors and builders over giant shared fixture modules.
- Keep immutable sample data easy to read and mutable state recreated per test.
- Use temporary directories and ephemeral resources per test when possible.
- Keep async runtime setup explicit for async tests.
- Prefer typed helpers that preserve domain invariants over loose fixture maps.

Review heuristics:

- async tests that can hang or depend on timing
- weak matching on error variants or state transitions
- shared mutable state across tests
- helpers that hide too much setup or ownership
- builders that make invalid states too easy to construct
- missing coverage for cancellation, invalid input, or partial-failure behavior
