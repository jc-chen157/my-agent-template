# Rust Testing Patterns Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `rust-server` / `rust-desktop` when reviewing or writing Rust tests.

## Preferred Stack

- `cargo test`
- `#[test]`
- `#[tokio::test]` when async is required

## Guidance

- Prefer outcome-focused tests over implementation-detail assertions.
- Use the type system in tests too; avoid loose strings or maps when strong types improve clarity.
- Keep async tests explicit about task coordination and shutdown.
- Test error variants and edge cases directly, not only happy paths.
- Use integration tests for crate boundaries and end-to-end flows when boundary behavior matters.

## Review Heuristics

- Async tests that can hang or depend on timing
- Weak matching on error variants or state transitions
- Overuse of shared helpers that hide ownership and setup
- Tests that fight the borrow checker by cloning everything unnecessarily
- Missing coverage for cancellation, invalid input, or partial-failure behavior
