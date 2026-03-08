---
name: python-backend
description: Use this skill for Python backend work and Python backend code review. It provides stack-specific guidance for Django, Flask, FastAPI, SQLAlchemy, and pytest.
---

# Python Backend

Use these defaults:

- Django
- Flask
- FastAPI
- SQLAlchemy
- pytest

Guidance:

- Keep business logic in plain Python modules instead of framework glue.
- Choose Django for integrated product backends, Flask for thin explicit services, and FastAPI for typed API ergonomics.
- Be explicit about sync versus async boundaries.
- Keep session and transaction scope understandable.
- Use pytest fixtures to reduce repetition, not to hide setup.

Review heuristics:

- ORM query explosions and weak query shape
- Confused sync and async usage
- Fat views, route handlers, or dependency functions
- Fixture sprawl and brittle tests
- Global state leakage
- Unclear validation and serialization boundaries
