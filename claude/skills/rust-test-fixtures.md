# Rust Test Fixtures Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `rust-server` / `rust-desktop` when Rust tests need better fixture structure or isolation.

## Guidance

- Prefer small helper constructors and builders over giant shared fixture modules.
- Keep immutable sample data easy to read and mutable state recreated per test.
- Use temporary directories and ephemeral resources per test when possible.
- Keep async runtime setup explicit for async tests.
- Use integration-test helpers only when multiple tests truly share the same boundary setup.
- Prefer typed helpers that preserve domain invariants over loose fixture maps.

## Review Heuristics

- Helpers that hide too much setup or ownership
- Shared mutable state across tests
- Async fixture setup that obscures runtime behavior
- Builders that make invalid states too easy to construct
- Integration helpers doing work that belongs in the test body
