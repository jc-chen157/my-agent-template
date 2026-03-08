---
name: python-test-fixtures
description: Use this skill for Python test fixture design and shared setup. It provides guidance for pytest fixtures, fixture scope, app/client setup, and DB/session isolation.
---

# Python Test Fixtures

Use this skill when Python tests need better setup and fixture structure.

Guidance:

- Use `pytest` fixtures to remove repetition, not to hide the setup story.
- Prefer narrow fixtures composed together over giant fixture pyramids.
- Keep factory functions explicit for domain objects and request payloads.
- Be deliberate with fixture scope; default to function scope unless broader reuse is clearly safe.
- For DB-backed tests, make session and rollback behavior explicit.
- Keep framework app/client fixtures separate from domain-level test data helpers.

Review heuristics:

- fixture sprawl and difficult-to-follow dependency chains
- session leakage across tests
- overly broad fixture scope
- magic defaults that make scenarios ambiguous
- shared global mocks or monkeypatches not reset cleanly
