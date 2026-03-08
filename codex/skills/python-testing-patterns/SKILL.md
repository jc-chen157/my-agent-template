---
name: python-testing-patterns
description: Use this skill for Python testing patterns. It provides guidance for pytest parameterization, Django/Flask/FastAPI test boundaries, async tests, and SQLAlchemy test behavior.
---

# Python Testing Patterns

Use this skill when reviewing or writing Python tests.

Guidance:

- Prefer `pytest` parameterization for behavior matrices.
- Test plain Python business logic directly before reaching for full framework tests.
- Use app/test clients for HTTP behavior and keep serialization/auth behavior explicit.
- Be deliberate about sync versus async test execution.
- For SQLAlchemy, make transaction boundaries and cleanup strategy obvious.
- Use monkeypatching narrowly and restore state cleanly.

Review heuristics:

- fixture-heavy tests that hide the scenario
- ORM-backed tests with unclear rollback or cleanup semantics
- async tests that are accidentally sync or vice versa
- weak assertions on error responses or validation behavior
- missing malformed-input, auth, or partial-failure coverage
