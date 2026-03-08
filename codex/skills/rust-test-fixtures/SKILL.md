---
name: rust-test-fixtures
description: Use this skill for Rust test fixture design and shared setup. It provides guidance for builders, temporary resources, async test setup, and isolated fixtures that preserve domain invariants.
---

# Rust Test Fixtures

Use this skill when Rust tests need better setup and fixture structure.

Guidance:

- Prefer small helper constructors and builders over giant shared fixture modules.
- Keep immutable sample data easy to read and mutable state recreated per test.
- Use temporary directories and ephemeral resources per test when possible.
- Keep async runtime setup explicit for async tests.
- Use integration-test helpers only when multiple tests truly share the same boundary setup.
- Prefer typed helpers that preserve domain invariants over loose fixture maps.

Review heuristics:

- helpers that hide too much setup or ownership
- shared mutable state across tests
- async fixture setup that obscures runtime behavior
- builders that make invalid states too easy to construct
- integration helpers doing work that belongs in the test body
