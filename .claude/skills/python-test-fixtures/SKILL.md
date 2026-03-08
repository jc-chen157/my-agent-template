# Python Test Fixtures Skill

Organize reusable test helpers, fixtures, and shared setup in Python projects.

## When to Use
- Tests share common setup logic
- Multiple test modules need the same infrastructure (e.g., database, containers)
- User says "refactor test setup" / "reduce test boilerplate" / "share test helpers"
- Setting up integration test infrastructure

---

## Fixture Organization Strategy

```
project/
├── src/mypackage/
│   ├── order/
│   │   ├── service.py
│   │   └── repository.py
│   └── user/
│       └── service.py
├── tests/
│   ├── conftest.py                  # Root: fixtures shared by all tests
│   ├── unit/
│   │   ├── conftest.py              # Unit-specific fixtures (mocks, fakes)
│   │   ├── test_order_service.py
│   │   └── test_user_service.py
│   └── integration/
│       ├── conftest.py              # Integration-specific (DB, containers)
│       ├── test_order_repo.py
│       └── test_user_repo.py
```

### Decision Tree

```
Do multiple tests in THIS module share the same setup?
  ├── YES → Add a fixture in the same test file or the nearest conftest.py
  └── NO  → Inline the setup

Do multiple MODULES share the same setup?
  ├── YES → Move the fixture up to the appropriate conftest.py
  └── NO  → Keep it local

Is this setup for integration tests (DB, containers, external services)?
  ├── YES → Put it in tests/integration/conftest.py
  └── NO  → Keep it in tests/conftest.py or tests/unit/conftest.py
```

---

## conftest.py Hierarchy

pytest auto-discovers fixtures in `conftest.py` files. No imports needed — fixtures are available to all tests in the same directory and below.

```python
# tests/conftest.py — available to ALL tests
@pytest.fixture
def sample_user():
    return User(name="Alice", email="alice@test.com")

@pytest.fixture
def sample_order():
    return Order(
        id="test-order-1",
        user_id="test-user-1",
        status="pending",
        items=[Item(sku="ITEM-1", qty=1, price=10.0)],
    )
```

```python
# tests/unit/conftest.py — available to unit tests only
@pytest.fixture
def mock_order_repo(mocker):
    return mocker.Mock(spec=OrderRepository)

@pytest.fixture
def mock_notifier(mocker):
    return mocker.Mock(spec=NotificationSender)

@pytest.fixture
def order_service(mock_order_repo, mock_notifier):
    return OrderService(repo=mock_order_repo, notifier=mock_notifier)
```

```python
# tests/integration/conftest.py — available to integration tests only
@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg

@pytest.fixture
def db_session(postgres):
    engine = create_engine(postgres.get_connection_url())
    with Session(engine) as session:
        yield session
        session.rollback()
```

Fixtures in child `conftest.py` files can override parent fixtures with the same name.

---

## Factory Fixtures

When tests need variants of the same object, use a factory fixture instead of many specialized fixtures.

```python
@pytest.fixture
def make_order():
    """Factory that returns fresh Order instances with sensible defaults."""
    def _make(
        id="test-order-1",
        user_id="test-user-1",
        status="pending",
        items=None,
    ):
        return Order(
            id=id,
            user_id=user_id,
            status=status,
            items=items if items is not None else [Item(sku="ITEM-1", qty=1, price=10.0)],
        )
    return _make
```

```python
# Usage — readable, flexible
def test_cancel_pending_order(order_service, make_order):
    order = make_order(status="pending")
    result = order_service.cancel(order)
    assert result.status == "cancelled"

def test_cannot_cancel_shipped_order(order_service, make_order):
    order = make_order(status="shipped")
    with pytest.raises(OrderError, match="cannot cancel"):
        order_service.cancel(order)

def test_bulk_order(order_service, make_order):
    order = make_order(items=[
        Item(sku="A", qty=10, price=5.0),
        Item(sku="B", qty=20, price=3.0),
    ])
    result = order_service.place(order)
    assert result.total == pytest.approx(110.0)
```

Each call to the factory returns a fresh object. Do not cache or reuse mutable fixtures across tests.

---

## Fixture Scopes

| Scope | Lifecycle | Use for |
|-------|-----------|---------|
| `function` (default) | Fresh per test | Mutable state, mocks, most fixtures |
| `class` | Per test class | Shared setup within a class |
| `module` | Per test file | Expensive immutable resources shared across a file |
| `session` | Entire test run | Database containers, one-time infrastructure |

```python
# function scope (default) — fresh per test
@pytest.fixture
def order_service(mock_repo, mock_notifier):
    return OrderService(repo=mock_repo, notifier=mock_notifier)

# session scope — expensive, immutable, shared
@pytest.fixture(scope="session")
def db_container():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg
```

Prefer `function` scope. Use broader scopes only for expensive immutable resources that cannot leak state between tests.

---

## Yield Fixtures for Cleanup

Code before `yield` is setup; code after is teardown. Teardown runs even if the test fails.

```python
@pytest.fixture
def temp_config(tmp_path):
    config_file = tmp_path / "config.yaml"
    config_file.write_text("key: value")
    yield config_file
    # Cleanup runs after test, even on failure

@pytest.fixture
def db_session(postgres):
    engine = create_engine(postgres.get_connection_url())
    session = Session(engine)
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def patched_env(monkeypatch):
    monkeypatch.setenv("API_KEY", "test-key-123")
    monkeypatch.setenv("ENV", "test")
    yield
    # monkeypatch auto-restores after test
```

---

## Testcontainers for Integration Tests

### Session-Scoped Container

```python
# tests/integration/conftest.py
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="session")
def postgres():
    with PostgresContainer("postgres:16-alpine") as pg:
        engine = create_engine(pg.get_connection_url())
        Base.metadata.create_all(engine)  # Run migrations
        yield pg

@pytest.fixture
def db_session(postgres):
    engine = create_engine(postgres.get_connection_url())
    with Session(engine) as session:
        yield session
        session.rollback()  # Isolation: undo changes per test
```

### Truncation for Isolation

```python
@pytest.fixture
def clean_db(db_session):
    """Truncate tables before each test for clean state."""
    db_session.execute(text("TRUNCATE TABLE orders, users CASCADE"))
    db_session.commit()
    yield db_session
```

---

## Integration Test Separation

### Directory Structure

```
tests/
├── conftest.py          # Shared fixtures
├── unit/                # Fast, no external deps
│   ├── conftest.py
│   └── test_*.py
└── integration/         # Slow, needs containers/DB
    ├── conftest.py
    └── test_*.py
```

### Markers

```python
# tests/integration/conftest.py
import pytest

# Auto-apply marker to all tests in this directory
pytestmark = pytest.mark.integration
```

```toml
# pyproject.toml
[tool.pytest.ini_options]
markers = [
    "integration: marks tests as integration (deselect with '-m \"not integration\"')",
]
```

```bash
# Run only unit tests (fast)
pytest tests/unit/
pytest -m "not integration"

# Run only integration tests
pytest tests/integration/
pytest -m integration
```

---

## Built-in Test Fixtures

pytest provides several useful built-in fixtures:

| Fixture | Purpose |
|---------|---------|
| `tmp_path` | Temporary directory (auto-cleaned), returns `pathlib.Path` |
| `tmp_path_factory` | Session-scoped temp directory factory |
| `caplog` | Capture log output |
| `capsys` | Capture stdout/stderr |
| `monkeypatch` | Temporarily modify objects, env vars, sys.path |
| `request` | Access test metadata (markers, params, fixture info) |

```python
def test_with_temp_file(tmp_path):
    data_file = tmp_path / "data.json"
    data_file.write_text('{"key": "value"}')
    result = load_config(data_file)
    assert result["key"] == "value"

def test_logs_warning(caplog):
    with caplog.at_level(logging.WARNING):
        process_invalid_data({})
    assert "invalid data" in caplog.text

def test_with_env(monkeypatch):
    monkeypatch.setenv("DATABASE_URL", "sqlite:///:memory:")
    config = load_config()
    assert config.database_url == "sqlite:///:memory:"
```

---

## When NOT to Create Shared Fixtures

- Fixture is used in only one test file — define it in that file or inline it
- Fixture hides important test setup logic — keep it visible in the test
- Fixture adds indirection without reducing duplication — skip it
- Over-abstracted factories make tests harder to read — keep it simple
- A plain `dict` or constructor call is clearer than `make_widget()` for trivial objects

---

## Related Skills

- `python-testing-patterns` - pytest, pytest-mock, parametrize patterns
- `python-test-engineer` - Comprehensive test review and coverage analysis
