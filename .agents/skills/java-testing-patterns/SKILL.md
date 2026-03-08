# Java Testing Patterns Skill

JUnit 5, Mockito, and AssertJ patterns for Java tests.

## When to Use
- Writing unit tests in Java
- Setting up mocks with Mockito
- Structuring parameterized test cases
- User says "write tests" / "add unit tests" / "test this function"

---

## Framework Stack

| Tool | Purpose |
|------|---------|
| JUnit 5 | Test framework (`@Test`, `@ParameterizedTest`, lifecycle) |
| Mockito | Mocking collaborators at external boundaries (`@Mock`, `when`/`verify`) |
| AssertJ | Fluent assertions (preferred over JUnit assertions) |

---

## Parameterized Tests

Parameterized tests are Java's equivalent of table-driven tests. Use them when the same behavior is naturally expressed as data. Prefer separate named tests when scenario clarity matters more than compactness.

### @MethodSource (Primary Pattern — Complex Cases)

Use for test cases with multiple inputs, expected outputs, and error conditions.

```java
@ParameterizedTest(name = "{0}")
@MethodSource("discountCases")
@DisplayName("calculateDiscount")
void calculateDiscount(String scenario, double price, int quantity, double expected, Class<? extends Exception> expectedException) {
    if (expectedException != null) {
        assertThatThrownBy(() -> calculator.calculateDiscount(price, quantity))
            .isInstanceOf(expectedException);
        return;
    }

    double result = calculator.calculateDiscount(price, quantity);
    assertThat(result).isCloseTo(expected, within(0.01));
}

static Stream<Arguments> discountCases() {
    return Stream.of(
        Arguments.of("standard discount for bulk order", 100.0, 10, 950.0, null),
        Arguments.of("no discount for small order", 100.0, 2, 200.0, null),
        Arguments.of("zero quantity returns error", 100.0, 0, 0.0, IllegalArgumentException.class),
        Arguments.of("negative price returns error", -10.0, 5, 0.0, IllegalArgumentException.class)
    );
}
```

### @CsvSource (Simple Primitive Inputs)

Use for utility methods with simple input/output mapping.

```java
@ParameterizedTest(name = "\"{0}\" → {1}")
@CsvSource({
    "user@example.com, true",
    "admin@corp.org, true",
    "'', false",
    "missing-at-sign, false",
    "no-domain@, false",
    "@no-local.com, false"
})
@DisplayName("isValidEmail")
void isValidEmail(String input, boolean expected) {
    assertThat(EmailValidator.isValidEmail(input)).isEqualTo(expected);
}
```

### @ValueSource (Single-Argument Edge Cases)

Use for testing one parameter across many values.

```java
@ParameterizedTest
@ValueSource(strings = {"", " ", "\t", "\n"})
@DisplayName("rejects blank input")
void rejectsBlankInput(String input) {
    assertThatThrownBy(() -> sanitizer.sanitize(input))
        .isInstanceOf(IllegalArgumentException.class);
}

@ParameterizedTest
@ValueSource(ints = {0, -1, -100, Integer.MIN_VALUE})
@DisplayName("rejects non-positive quantities")
void rejectsNonPositiveQuantity(int quantity) {
    assertThatThrownBy(() -> calculator.calculate(10.0, quantity))
        .isInstanceOf(IllegalArgumentException.class);
}
```

### @NullAndEmptySource (Null/Empty Coverage)

```java
@ParameterizedTest
@NullAndEmptySource
@ValueSource(strings = {" ", "\t"})
@DisplayName("rejects null, empty, and blank input")
void rejectsInvalidInput(String input) {
    assertThatThrownBy(() -> parser.parse(input))
        .isInstanceOf(IllegalArgumentException.class);
}
```

---

## Mockito Patterns

### Per-Test Mock Setup (Preferred)

Each test method configures its own mock behavior. Mocks are fresh per test via `@ExtendWith(MockitoExtension.class)`. Explicit constructor wiring is often the clearest default; `@InjectMocks` is fine when it reduces noise without hiding important setup.

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock
    private OrderRepository orderRepository;

    @Mock
    private NotificationSender notificationSender;

    private OrderService orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderService(orderRepository, notificationSender);
    }

    @Test
    @DisplayName("places order successfully")
    void placesOrderSuccessfully() {
        Order order = OrderTestFixtures.defaultOrder();
        when(orderRepository.save(any(Order.class))).thenReturn(order);
        doNothing().when(notificationSender).send(anyString(), anyString());

        OrderResult result = orderService.placeOrder(order);

        assertThat(result.getStatus()).isEqualTo("confirmed");
        verify(orderRepository).save(order);
        verify(notificationSender).send(eq(order.getUserEmail()), anyString());
    }

    @Test
    @DisplayName("returns error when repository save fails")
    void returnsErrorWhenSaveFails() {
        Order order = OrderTestFixtures.defaultOrder();
        when(orderRepository.save(any(Order.class)))
            .thenThrow(new RuntimeException("db connection lost"));

        assertThatThrownBy(() -> orderService.placeOrder(order))
            .isInstanceOf(OrderException.class)
            .hasMessageContaining("failed to save order");

        verify(notificationSender, never()).send(anyString(), anyString());
    }

    @Test
    @DisplayName("succeeds even when notification fails")
    void succeedsWhenNotificationFails() {
        Order order = OrderTestFixtures.defaultOrder();
        when(orderRepository.save(any(Order.class))).thenReturn(order);
        doThrow(new RuntimeException("notification service down"))
            .when(notificationSender).send(anyString(), anyString());

        OrderResult result = orderService.placeOrder(order);

        assertThat(result.getStatus()).isEqualTo("confirmed");
    }
}
```

### Shared Mock Setup (Rare)

Use `@BeforeEach` for shared setup **only** when ALL test cases need the exact same mock behavior.

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private CacheService cacheService;
    private UserService userService;

    @BeforeEach
    void setUp() {
        // ALL tests need cache to return miss so we always hit the repository
        when(cacheService.get(anyString())).thenReturn(Optional.empty());
        userService = new UserService(userRepository, cacheService);
    }

    @Test
    @DisplayName("returns user when found in repository")
    void returnsUserWhenFound() {
        // Per-test setup on top of shared setup
        when(userRepository.findById("user-1"))
            .thenReturn(Optional.of(new User("user-1", "Alice")));

        User result = userService.getProfile("user-1");

        assertThat(result.getName()).isEqualTo("Alice");
    }

    @Test
    @DisplayName("throws when user not found")
    void throwsWhenUserNotFound() {
        when(userRepository.findById("user-999"))
            .thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.getProfile("user-999"))
            .isInstanceOf(UserNotFoundException.class);
    }
}
```

### Mock Verification Patterns

```java
// Verify method was called
verify(mock).method(args);

// Verify never called
verify(mock, never()).method(any());

// Verify call count
verify(mock, times(2)).method(any());
verify(mock, atLeastOnce()).method(any());

// Verify no other interactions
verifyNoMoreInteractions(mock); // use sparingly; brittle when overused

// Verify call order
InOrder inOrder = inOrder(repoMock, notifierMock);
inOrder.verify(repoMock).save(any());
inOrder.verify(notifierMock).send(anyString(), anyString());

// Argument capture
ArgumentCaptor<Order> captor = ArgumentCaptor.forClass(Order.class);
verify(repository).save(captor.capture());
assertThat(captor.getValue().getStatus()).isEqualTo(OrderStatus.CONFIRMED);
```

---

## Assertion Patterns

### assertAll vs Direct Assertions

| Pattern | On failure... | Use when |
|---------|---------------|----------|
| `assertAll(() -> ...)` | Runs ALL checks, reports all failures | Multiple value checks — see everything that's wrong |
| Direct assertions / AssertJ chains | Each failing assertion stops that statement | Preconditions or a few critical checks |
| `assertThrows` | Verifies exception thrown | Error path testing |

If you already standardize on AssertJ, `SoftAssertions.assertSoftly(...)` is also a good fit for grouped assertions.

```java
@Test
void processOrder_returnsCompleteResult() {
    OrderResult result = service.processOrder(order);

    // Precondition — stop if null
    assertThat(result).isNotNull();

    // Grouped checks — see all failures at once
    assertAll(
        () -> assertThat(result.getStatus()).isEqualTo("confirmed"),
        () -> assertThat(result.getTotal()).isEqualByComparingTo(new BigDecimal("99.99")),
        () -> assertThat(result.getItems()).hasSize(3),
        () -> assertThat(result.getCreatedAt()).isNotNull()
    );
}
```

### AssertJ Common Assertions (Preferred)

```java
// Equality
assertThat(actual).isEqualTo(expected);
assertThat(actual).isNotEqualTo(unexpected);

// Null checks
assertThat(result).isNull();
assertThat(result).isNotNull();

// Boolean
assertThat(condition).isTrue();
assertThat(condition).isFalse();

// Strings
assertThat(result).contains("expected");
assertThat(result).startsWith("prefix");
assertThat(result).matches("regex.*pattern");
assertThat(result).isBlank();

// Numbers
assertThat(result).isGreaterThan(0);
assertThat(result).isBetween(1, 10);
assertThat(result).isCloseTo(3.14, within(0.01));

// BigDecimal (use isEqualByComparingTo, NOT isEqualTo)
assertThat(amount).isEqualByComparingTo(new BigDecimal("99.99"));

// Collections
assertThat(list).hasSize(3);
assertThat(list).contains(element);
assertThat(list).containsExactly(a, b, c);          // order matters
assertThat(list).containsExactlyInAnyOrder(c, a, b); // order independent
assertThat(list).isEmpty();

// Exceptions
assertThatThrownBy(() -> service.process(null))
    .isInstanceOf(IllegalArgumentException.class)
    .hasMessageContaining("must not be null");

assertThatCode(() -> service.process(validInput))
    .doesNotThrowAnyException();

// Object field extraction
assertThat(users)
    .extracting("name", "email")
    .containsExactly(
        tuple("Alice", "alice@example.com"),
        tuple("Bob", "bob@example.com")
    );

// Optional
assertThat(optional).isPresent().hasValue(expected);
assertThat(optional).isEmpty();
```

---

## Unit Test Lifecycle

### Rules

- **`@BeforeEach` / `@AfterEach`** — preferred for unit test setup/teardown, especially with mutable state
- **`@BeforeAll` / `@AfterAll`** — acceptable only for immutable or expensive shared fixtures that cannot couple test cases

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private NotificationSender notificationSender;
    private OrderService orderService;

    @BeforeEach
    void setUp() {
        // Fresh instance per test — no shared state
        orderService = new OrderService(orderRepository, notificationSender);
    }

    @AfterEach
    void tearDown() {
        // Rarely needed with Mockito — mocks are reset automatically
        // Use only if your test modifies external state (files, system properties)
    }
}
```

> **If you see shared mutable state in a unit test, flag it.** In most cases that means refactoring to `@BeforeEach` / `@AfterEach`. `@BeforeAll` is only acceptable when the shared fixture is immutable and cannot make tests order-dependent.

---

## Naming Conventions

### Test Classes

```java
// Pattern: <ClassUnderTest>Test
class OrderServiceTest { }
class EmailValidatorTest { }
class PaymentGatewayTest { }
```

### Test Methods

```java
// Option 1: @DisplayName (preferred — readable test reports)
@Test
@DisplayName("returns error when user not found")
void returnsErrorWhenUserNotFound() { }

// Option 2: method name pattern (when @DisplayName feels redundant)
// Pattern: methodUnderTest_condition_expectedResult
@Test
void placeOrder_withEmptyItems_throwsIllegalArgumentException() { }
```

### Parameterized Test Names

```java
@ParameterizedTest(name = "{0}")    // uses first argument as test name
@MethodSource("cases")
void calculateDiscount(String scenario, ...) { }

@ParameterizedTest(name = "\"{0}\" → {1}")    // custom format
@CsvSource({...})
void isValidEmail(String input, boolean expected) { }
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Do Instead |
|--------------|---------|------------|
| One giant test method | Hard to identify failures | Separate `@Test` methods or `@ParameterizedTest` |
| Shared mutable state in unit tests | Order-dependent, flaky tests | Prefer `@BeforeEach`; use `@BeforeAll` only for immutable expensive fixtures |
| Shared mutable mocks | Tests affect each other | Fresh mocks per test via `MockitoExtension` |
| Mocking everything | Tests break on refactor | Mock only external boundaries (repos, clients) |
| `new ConcreteClass()` in production code | Harder to substitute and isolate | Constructor injection or an explicit factory boundary |
| Testing private methods via reflection | Coupled to implementation | Test via public API |
| `Thread.sleep` in tests | Flaky, slow | Use `Awaitility` or mock the clock |
| No assertion message | Hard to debug | Use AssertJ's fluent `.as("context")` or `assertAll` |
| `@Autowired` field injection | Hidden dependencies, hard to test | Constructor injection |
| `@SpringBootTest` for unit tests | Slow, loads entire context | `@ExtendWith(MockitoExtension.class)` |

---

## Related Skills

- `java-test-fixtures` - Test helper organization, builders, lifecycle patterns
- `java-test-engineer` - Comprehensive test review and coverage analysis
