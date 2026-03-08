# Python Test Fixtures Skill

Use this skill with `reviewer-test-quality`, `backend-engineer`, or `python-backend` when Python tests need fixture cleanup, fixture factoring, or better isolation.

## Guidance

- Use `pytest` fixtures to remove repetition, not to hide the setup story.
- Prefer narrow fixtures composed together over giant fixture pyramids.
- Keep factory functions explicit for domain objects and request payloads.
- Be deliberate with fixture scope; default to function scope unless broader reuse is clearly safe.
- For DB-backed tests, make session and rollback behavior explicit.
- Keep Django, Flask, and FastAPI app/client fixtures separate from domain-level test data helpers.

## Review Heuristics

- Fixture sprawl and difficult-to-follow dependency chains
- Session leakage across tests
- Overly broad fixture scope
- Magic defaults that make scenarios ambiguous
- Shared global mocks or monkeypatches not reset cleanly
