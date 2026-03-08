# Python Backend Skill

Use this skill with `backend-engineer` or `code-review-engineer` when the project is Python backend work.

## Stack Defaults

- Django
- Flask
- FastAPI
- SQLAlchemy
- pytest

## Implementation Guidance

- Keep business logic in plain Python modules instead of framework glue.
- Choose Django for integrated product backends, Flask for thin explicit services, and FastAPI for typed API ergonomics.
- Be explicit about sync versus async boundaries.
- Keep session and transaction scope understandable.
- Use pytest fixtures to reduce repetition, not to hide setup.

## Review Heuristics

- ORM query explosions and weak query shape
- Confused sync and async usage
- Fat views, route handlers, or dependency functions
- Fixture sprawl and brittle tests
- Global state leakage
- Unclear validation and serialization boundaries
