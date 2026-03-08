# Python Testing Patterns Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `python-backend` when reviewing or writing Python tests.

## Preferred Stack

- pytest
- Django test tools where relevant
- Flask or FastAPI test clients
- SQLAlchemy test session patterns

## Guidance

- Prefer `pytest` parameterization for behavior matrices.
- Test plain Python business logic directly before reaching for full framework tests.
- Use app/test clients for HTTP behavior and keep serialization/auth behavior explicit.
- Be deliberate about sync versus async test execution.
- For SQLAlchemy, make transaction boundaries and cleanup strategy obvious.
- Use monkeypatching narrowly and restore state cleanly.

## Review Heuristics

- Fixture-heavy tests that hide the scenario
- ORM-backed tests with unclear rollback or cleanup semantics
- Async tests that are accidentally sync or vice versa
- Weak assertions on error responses or validation behavior
- Missing malformed-input, auth, or partial-failure coverage
