---
name: python-testing
description: Use this skill for Python tests, test review, and pytest fixture or shared setup design. It covers pytest parameterization, Django, Flask, FastAPI, SQLAlchemy, async tests, fixture scope, app/client setup, and DB/session isolation.
---

# Python Testing

Use this skill when writing, reviewing, or reshaping Python tests.

Testing guidance:

- Prefer `pytest` parameterization for behavior matrices.
- Test plain Python business logic directly before reaching for full framework tests.
- Use app or test clients for HTTP behavior and keep serialization and auth behavior explicit.
- Be deliberate about sync versus async test execution.
- For SQLAlchemy, make transaction boundaries and cleanup strategy obvious.
- Use monkeypatching narrowly and restore state cleanly.

Fixture guidance:

- Use `pytest` fixtures to remove repetition, not to hide the setup story.
- Prefer narrow fixtures composed together over giant fixture pyramids.
- Keep factory functions explicit for domain objects and request payloads.
- Default to function-scoped fixtures unless broader reuse is clearly safe.
- Keep framework app/client fixtures separate from domain-level test data helpers.

Review heuristics:

- fixture-heavy tests that hide the scenario
- unclear rollback or cleanup semantics in DB-backed tests
- async tests that are accidentally sync or vice versa
- overly broad fixture scope
- shared global mocks or monkeypatches not reset cleanly
- missing malformed-input, auth, or partial-failure coverage
