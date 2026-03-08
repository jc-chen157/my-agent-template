# Python Testing Patterns Skill

pytest, pytest-mock, and idiomatic Python testing patterns.

## When to Use
- Writing unit or integration tests in Python
- Setting up mocks with pytest-mock
- Structuring parametrized test cases
- User says "write tests" / "add tests" / "test this function"

---

## Framework Stack

| Tool | Purpose |
|------|---------|
| `pytest` | Test framework — discovery, fixtures, parametrize, plugins |
| `pytest-mock` | Pytest-native mocking via `mocker` fixture (wraps `unittest.mock`) |
| `pytest-cov` | Coverage measurement (wraps `coverage.py`) |
| `pytest-asyncio` | Async test support (`@pytest.mark.asyncio`) |

pytest is the standard choice. Plain `assert` statements with pytest's introspection give clear failure messages without special assertion methods.

---

## Parametrized Tests

Python's equivalent of table-driven tests. Use `@pytest.mark.parametrize` when the same behavior is naturally expressed as data.

### Basic Parametrize

```python
@pytest.mark.parametrize("price, quantity, expected", [
    (100.0, 10, 950.0),
    (100.0, 2, 200.0),
    (50.0, 1, 50.0),
])
def test_calculate_total(price, quantity, expected):
    assert calculate_total(price, quantity) == expected
```

### Named Cases with pytest.param

```python
@pytest.mark.parametrize("email, expected", [
    pytest.param("user@example.com", True, id="valid email"),
    pytest.param("missing-at-sign", False, id="no @ symbol"),
    pytest.param("", False, id="empty string"),
    pytest.param(None, False, id="None input"),
])
def test_is_valid_email(email, expected):
    assert is_valid_email(email) == expected
```

### Parametrize with Expected Exceptions

```python
@pytest.mark.parametrize("amount, error_match", [
    pytest.param(-1, "must be positive", id="negative amount"),
    pytest.param(0, "must be positive", id="zero amount"),
])
def test_process_payment_rejects_invalid(amount, error_match):
    with pytest.raises(ValueError, match=error_match):
        process_payment(amount)
```

### Multiple Parametrize (Cartesian Product)

```python
@pytest.mark.parametrize("x", [1, 2, 3])
@pytest.mark.parametrize("y", [10, 20])
def test_multiply(x, y):
    assert multiply(x, y) == x * y
# Generates 6 test cases
```

---

## Fixtures

### Basic Fixture

```python
@pytest.fixture
def order_service(mock_repo, mock_notifier):
    return OrderService(repo=mock_repo, notifier=mock_notifier)

def test_place_order(order_service, mock_repo):
    mock_repo.save.return_value = Order(id="123", status="confirmed")

    result = order_service.place_order(Order(items=[Item("A", 2)]))

    assert result.status == "confirmed"
    mock_repo.save.assert_called_once()
```

### Fixture Scopes

| Scope | Lifecycle | Use for |
|-------|-----------|---------|
| `function` (default) | Fresh per test | Mutable state, mocks, most fixtures |
| `class` | Per test class | Shared setup within a class |
| `module` | Per test file | Expensive immutable resources |
| `session` | Entire test run | Database containers, one-time infra |

```python
# Default: function scope — fresh per test
@pytest.fixture
def user():
    return User(name="Alice", email="alice@test.com")

# Session scope — expensive, immutable, shared
@pytest.fixture(scope="session")
def db_container():
    container = PostgresContainer()
    container.start()
    yield container
    container.stop()
```

Prefer `function` scope. Use broader scopes only for expensive immutable resources that cannot leak state between tests.

### Yield Fixtures for Cleanup

```python
@pytest.fixture
def temp_config(tmp_path):
    config_file = tmp_path / "config.yaml"
    config_file.write_text("key: value")
    yield config_file
    # Cleanup runs even if the test fails
```

### conftest.py — Shared Fixtures

Fixtures in `conftest.py` are auto-discovered by all tests in the same directory and below. No imports needed.

```
tests/
├── conftest.py              # Shared across all tests
├── unit/
│   ├── conftest.py          # Shared across unit tests
│   ├── test_order_service.py
│   └── test_user_service.py
├── integration/
│   ├── conftest.py          # Integration-specific (DB, containers)
│   └── test_order_repo.py
```

```python
# tests/conftest.py — shared by all tests
@pytest.fixture
def sample_user():
    return User(name="Alice", email="alice@test.com")

# tests/integration/conftest.py — only for integration tests
@pytest.fixture(scope="session")
def postgres():
    container = PostgresContainer("postgres:16-alpine")
    container.start()
    yield container
    container.stop()

@pytest.fixture
def db_session(postgres):
    engine = create_engine(postgres.get_connection_url())
    session = Session(engine)
    yield session
    session.rollback()
    session.close()
```

### Factory Fixtures

When tests need variants of the same object, use a factory fixture.

```python
@pytest.fixture
def make_order():
    def _make(status="pending", items=None):
        return Order(
            id="test-order-1",
            status=status,
            items=items if items is not None else [Item("ITEM-1", 1, 10.0)],
        )
    return _make

def test_cancel_pending_order(order_service, make_order):
    order = make_order(status="pending")
    result = order_service.cancel(order)
    assert result.status == "cancelled"

def test_cannot_cancel_shipped_order(order_service, make_order):
    order = make_order(status="shipped")
    with pytest.raises(OrderError, match="cannot cancel"):
        order_service.cancel(order)
```

---

## Mocking with pytest-mock

### Basic Mocking

```python
def test_place_order(mocker):
    # Create mocks
    mock_repo = mocker.Mock(spec=OrderRepository)
    mock_notifier = mocker.Mock(spec=NotificationSender)

    mock_repo.save.return_value = Order(id="123", status="confirmed")

    service = OrderService(repo=mock_repo, notifier=mock_notifier)
    result = service.place_order(Order(items=[Item("A", 2)]))

    assert result.status == "confirmed"
    mock_repo.save.assert_called_once()
    mock_notifier.send.assert_called_once_with("Order confirmed", mocker.ANY)
```

### Patching (patch where USED, not where defined)

```python
# module_a.py defines: class EmailClient: ...
# module_b.py imports: from module_a import EmailClient

# ❌ WRONG: patching where it's defined
mocker.patch("module_a.EmailClient")

# ✅ CORRECT: patching where it's used
mocker.patch("module_b.EmailClient")
```

```python
def test_send_welcome(mocker):
    # Patch where the dependency is looked up
    mock_client = mocker.patch("myapp.services.email_client")
    mock_client.send.return_value = True

    result = send_welcome("user@example.com")

    assert result is True
    mock_client.send.assert_called_once_with(
        "user@example.com", subject="Welcome!", body=mocker.ANY
    )
```

### Use spec / autospec for Safety

Prefer `autospec=True`, `spec=...`, or `spec_set=...` when patching concrete callables and classes. They catch impossible calls and signature drift, but you do not need them on every fake or lightweight stub.

```python
def test_with_autospec(mocker):
    mock_repo = mocker.patch("myapp.services.order_repo", autospec=True)
    # Now mock_repo.save() will enforce the same signature as the real method
```

### Per-Test Mock Setup (Preferred)

Each test configures its own mock behavior. Avoid shared mutable mocks.

```python
# ✅ GOOD: each test sets up its own expectations
def test_order_found(mocker):
    mock_repo = mocker.Mock(spec=OrderRepository)
    mock_repo.find_by_id.return_value = Order(id="1", status="pending")
    service = OrderService(repo=mock_repo)

    result = service.get_order("1")
    assert result.status == "pending"

def test_order_not_found(mocker):
    mock_repo = mocker.Mock(spec=OrderRepository)
    mock_repo.find_by_id.return_value = None
    service = OrderService(repo=mock_repo)

    with pytest.raises(OrderNotFoundError):
        service.get_order("999")
```

### Mock as Fixture (Shared Setup)

Use when ALL tests in a class/file need the same mock wiring.

```python
@pytest.fixture
def mock_repo(mocker):
    return mocker.Mock(spec=OrderRepository)

@pytest.fixture
def mock_notifier(mocker):
    return mocker.Mock(spec=NotificationSender)

@pytest.fixture
def order_service(mock_repo, mock_notifier):
    return OrderService(repo=mock_repo, notifier=mock_notifier)

def test_place_order(order_service, mock_repo):
    mock_repo.save.return_value = Order(id="1", status="confirmed")
    result = order_service.place_order(Order(items=[Item("A", 2)]))
    assert result.status == "confirmed"
```

### AsyncMock

```python
@pytest.mark.asyncio
async def test_async_service(mocker):
    mock_client = mocker.AsyncMock(spec=HttpClient)
    mock_client.get.return_value = {"id": 1, "name": "Alice"}

    service = UserService(client=mock_client)
    user = await service.fetch_user(1)

    assert user.name == "Alice"
    mock_client.get.assert_awaited_once_with("/users/1")
```

---

## Assertions

### Plain assert (Preferred)

pytest rewrites `assert` statements to show detailed failure context. No special assertion methods needed.

```python
# Equality
assert result == expected
assert result != unexpected

# Truthiness
assert user.is_active
assert not user.is_banned

# Membership
assert "admin" in user.roles
assert item in collection

# Approximate (floats)
assert result == pytest.approx(3.14, abs=0.01)

# None
assert result is None
assert result is not None

# Type
assert isinstance(result, Order)
```

### Exception Testing

```python
# Basic
with pytest.raises(ValueError):
    process_payment(-1)

# With message matching
with pytest.raises(ValueError, match="must be positive"):
    process_payment(-1)

# Capture and inspect
with pytest.raises(OrderError) as exc_info:
    service.cancel_shipped_order("123")
assert exc_info.value.order_id == "123"
assert "cannot cancel" in str(exc_info.value)
```

### Built-in Fixtures

```python
# Temporary directory (auto-cleaned)
def test_file_processing(tmp_path):
    input_file = tmp_path / "data.csv"
    input_file.write_text("col1,col2\n1,2\n")
    result = process_csv(input_file)
    assert len(result) == 1

# Capture log output
def test_logs_warning(caplog):
    with caplog.at_level(logging.WARNING):
        process_invalid_data({})
    assert "invalid data" in caplog.text

# Capture stdout/stderr
def test_prints_result(capsys):
    print_report(data)
    captured = capsys.readouterr()
    assert "Total: 42" in captured.out

# Monkeypatch (set env vars, attributes)
def test_with_env_var(monkeypatch):
    monkeypatch.setenv("API_KEY", "test-key")
    config = load_config()
    assert config.api_key == "test-key"
```

---

## Async Testing

```python
import pytest
import pytest_asyncio

@pytest.mark.asyncio
async def test_fetch_user():
    service = UserService(client=HttpClient())
    user = await service.fetch_user(1)
    assert user.name == "Alice"

# Async fixture — requires @pytest_asyncio.fixture (not @pytest.fixture)
@pytest_asyncio.fixture
async def async_db_session():
    session = await create_async_session()
    yield session
    await session.rollback()
    await session.close()

@pytest.mark.asyncio
async def test_save_user(async_db_session):
    repo = UserRepository(session=async_db_session)
    user = await repo.save(User(name="Bob"))
    assert user.id is not None
```

---

## Integration Test Separation

### Directory Structure

```
tests/
├── conftest.py              # Shared fixtures
├── unit/
│   ├── conftest.py
│   ├── test_order_service.py
│   └── test_user_service.py
└── integration/
    ├── conftest.py          # DB containers, session fixtures
    ├── test_order_repo.py
    └── test_user_repo.py
```

### Markers

```python
# tests/integration/conftest.py
import pytest

# Mark all tests in this directory as integration
pytestmark = pytest.mark.integration
```

```python
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

# Run everything
pytest
```

### Testcontainers

```python
# tests/integration/conftest.py
from testcontainers.postgres import PostgresContainer

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

---

## Coverage

### Running Coverage

```bash
# Basic coverage
pytest --cov=mypackage tests/

# With branch coverage
pytest --cov=mypackage --cov-branch tests/

# HTML report
pytest --cov=mypackage --cov-report=html tests/

# Terminal + fail under threshold
pytest --cov=mypackage --cov-branch --cov-fail-under=85 tests/
```

### Configuration (pyproject.toml)

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
markers = [
    "integration: integration tests",
]

[tool.coverage.run]
branch = true
source = ["mypackage"]

[tool.coverage.report]
fail_under = 85
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
]
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Do Instead |
|--------------|---------|------------|
| Patching where defined, not where used | Mock doesn't apply to the right import | `mocker.patch("module_that_imports.ClassName")` |
| Missing `spec` / `autospec` on boundary mocks | Mock accepts impossible calls silently | Prefer `spec`, `spec_set`, or `autospec=True` when interface safety matters |
| Shared mutable fixtures at broad scope | Tests affect each other | Use `function` scope (default) for mutable fixtures |
| `time.sleep` in tests | Flaky, slow | Mock `time.sleep` or use `freezegun`/`time-machine` |
| Testing private `_methods` directly | Coupled to implementation | Test via public API |
| Over-mocking | Tests pass but real code fails | Mock only external boundaries (DB, HTTP, filesystem) |
| Pytest-native code leaning on `setUp`/`tearDown` everywhere | Less composable than fixtures | Prefer pytest fixtures with `yield` in pytest-native suites |
| Missing `match=` when message semantics matter | Can miss the wrong error text | Add `match=` when the message distinguishes valid vs invalid failures |
| `assert mock.called` | Doesn't verify arguments | Use `mock.assert_called_once_with(...)` |
| Fixtures returning mutable singletons | Shared state across tests | Return fresh objects per call |

---

## Related Skills

- `python-test-fixtures` — Fixture organization and conftest patterns
- `python-test-engineer` — Comprehensive test review and coverage analysis
