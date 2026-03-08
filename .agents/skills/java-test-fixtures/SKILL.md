# Java Test Fixtures Skill

Organize reusable test helpers, fixture builders, and shared setup in Java projects.

## When to Use
- Tests in the same package share common setup logic
- Multiple packages need the same test infrastructure (e.g., database, containers)
- User says "refactor test setup" / "reduce test boilerplate" / "share test helpers"
- Setting up integration test infrastructure

---

## Fixture Organization Strategy

```
project/
├── src/
│   ├── main/java/com/example/
│   │   ├── order/
│   │   │   └── OrderService.java
│   │   └── user/
│   │       └── UserService.java
│   ├── test/java/com/example/
│   │   ├── order/
│   │   │   ├── OrderServiceTest.java
│   │   │   └── OrderTestFixtures.java       # Same-package test helpers
│   │   ├── user/
│   │   │   ├── UserServiceTest.java
│   │   │   └── UserTestFixtures.java        # Same-package test helpers
│   │   └── support/                          # Cross-package shared helpers
│   │       ├── TestDatabaseHelper.java
│   │       ├── TestFixtureBuilders.java
│   │       └── TestHttpHelper.java
│   └── integrationTest/java/com/example/    # One option for a dedicated integration path
│       ├── order/
│       │   └── OrderRepositoryIT.java
│       ├── user/
│       │   └── UserRepositoryIT.java
│       └── support/
│           └── AbstractIntegrationTest.java  # Shared integration base class
```

### Decision Tree

```
Do multiple tests in THIS package share the same setup?
  ├── YES → Create XxxTestFixtures.java in the same test package
  └── NO  → Inline the setup

Do multiple PACKAGES share the same setup?
  ├── YES → Create a shared support/ package under src/test/java
  └── NO  → Keep it in the package-level fixtures class

Is this setup for integration tests (DB, containers, external services)?
  ├── YES → Put it in a dedicated integration path
  │         (source set, tagged suite, or build-profile split)
  └── NO  → Keep it in src/test/java/
```

---

## Same-Package Test Helpers

Create `XxxTestFixtures.java` as a utility class with static factory methods for simple immutable defaults.

```java
// src/test/java/com/example/order/OrderTestFixtures.java
package com.example.order;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public final class OrderTestFixtures {

    private OrderTestFixtures() {} // utility class — no instantiation

    public static Order defaultOrder() {
        return Order.builder()
            .id("test-order-1")
            .userId("test-user-1")
            .status(OrderStatus.PENDING)
            .items(List.of(defaultItem()))
            .createdAt(LocalDateTime.of(2025, 1, 1, 0, 0))
            .build();
    }

    public static Order orderWithStatus(OrderStatus status) {
        return Order.builder()
            .id("test-order-1")
            .userId("test-user-1")
            .status(status)
            .items(List.of(defaultItem()))
            .createdAt(LocalDateTime.of(2025, 1, 1, 0, 0))
            .build();
    }

    public static Order orderWithItems(Item... items) {
        return Order.builder()
            .id("test-order-1")
            .userId("test-user-1")
            .status(OrderStatus.PENDING)
            .items(List.of(items))
            .createdAt(LocalDateTime.of(2025, 1, 1, 0, 0))
            .build();
    }

    public static Item defaultItem() {
        return new Item("ITEM-1", 1, BigDecimal.TEN);
    }

    public static Item item(String sku, int qty, String price) {
        return new Item(sku, qty, new BigDecimal(price));
    }
}
```

### Usage in Tests

```java
import static com.example.order.OrderTestFixtures.*;

@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    private OrderService orderService;

    @BeforeEach
    void setUp() {
        orderService = new OrderService(orderRepository);
    }

    @Test
    @DisplayName("places standard order successfully")
    void placesStandardOrder() {
        Order order = defaultOrder();
        when(orderRepository.save(any())).thenReturn(order);

        OrderResult result = orderService.placeOrder(order);

        assertThat(result.getStatus()).isEqualTo("confirmed");
    }

    @Test
    @DisplayName("applies discount for bulk order")
    void appliesDiscountForBulkOrder() {
        Order order = orderWithItems(
            item("A", 10, "5.00"),
            item("B", 20, "3.00")
        );
        when(orderRepository.save(any())).thenReturn(order);

        OrderResult result = orderService.placeOrder(order);

        assertThat(result.getTotal()).isEqualByComparingTo(new BigDecimal("100.00"));
    }
}
```

Each fixture method should return a fresh object. Do not cache and reuse mutable entity instances across tests.

---

## Test Data Builders

For complex objects, use the Builder pattern — Java's idiomatic equivalent of Go's functional options.

```java
// src/test/java/com/example/order/OrderBuilder.java
package com.example.order;

public class OrderBuilder {

    private String id = "test-order-1";
    private String userId = "test-user-1";
    private OrderStatus status = OrderStatus.PENDING;
    private List<Item> items = List.of(new Item("ITEM-1", 1, BigDecimal.TEN));
    private LocalDateTime createdAt = LocalDateTime.of(2025, 1, 1, 0, 0);

    public static OrderBuilder anOrder() {
        return new OrderBuilder();
    }

    public OrderBuilder withId(String id) { this.id = id; return this; }
    public OrderBuilder withUserId(String userId) { this.userId = userId; return this; }
    public OrderBuilder withStatus(OrderStatus status) { this.status = status; return this; }
    public OrderBuilder withItems(List<Item> items) { this.items = items; return this; }
    public OrderBuilder withItems(Item... items) { this.items = List.of(items); return this; }
    public OrderBuilder withCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; return this; }

    public Order build() {
        return new Order(id, userId, status, items, createdAt);
    }
}
```

```java
// Usage — readable, flexible
import static com.example.order.OrderBuilder.anOrder;

Order order = anOrder()
    .withStatus(OrderStatus.SHIPPED)
    .withItems(item("X", 5, "20.00"))
    .build();
```

---

## Cross-Package Shared Helpers

For infrastructure shared across packages: database setup, HTTP helpers, common assertions.

### Database Test Helper

```java
// src/test/java/com/example/support/TestDatabaseHelper.java
package com.example.support;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Arrays;

public final class TestDatabaseHelper {

    private TestDatabaseHelper() {}

    /**
     * Truncates the given tables. Use in @BeforeEach for test isolation.
     * Keep this limited to fixed, test-owned table names.
     */
    public static void truncateTables(DataSource dataSource, String... tables) {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            for (String table : tables) {
                stmt.execute("TRUNCATE TABLE " + table + " CASCADE");
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to truncate tables: " + Arrays.toString(tables), e);
        }
    }

    /**
     * Executes a SQL script against the datasource.
     */
    public static void executeSql(DataSource dataSource, String sql) {
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (Exception e) {
            throw new RuntimeException("Failed to execute SQL", e);
        }
    }
}
```

### HTTP Test Helper

```java
// src/test/java/com/example/support/TestHttpHelper.java
package com.example.support;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;

public final class TestHttpHelper {

    private TestHttpHelper() {}

    public static ResultActions postJson(MockMvc mockMvc, ObjectMapper objectMapper, String path, Object body) throws Exception {
        return mockMvc.perform(post(path)
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(body)));
    }

    public static ResultActions getJson(MockMvc mockMvc, String path) throws Exception {
        return mockMvc.perform(get(path)
            .accept(MediaType.APPLICATION_JSON));
    }

    public static <T> T parseResponse(ResultActions result, ObjectMapper objectMapper, Class<T> type) throws Exception {
        String json = result.andReturn().getResponse().getContentAsString();
        return objectMapper.readValue(json, type);
    }
}
```

If you are testing Spring MVC controllers, prefer the application-configured `ObjectMapper` from the test context over `new ObjectMapper()` so serialization behavior matches production.

---

## Lifecycle Patterns

### Unit Tests: Prefer @BeforeEach / @AfterEach

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {

    @Mock private OrderRepository orderRepository;
    @Mock private NotificationSender notificationSender;
    private OrderService orderService;

    @BeforeEach
    void setUp() {
        // Fresh instance per test — no shared mutable state
        orderService = new OrderService(orderRepository, notificationSender);
    }

    @AfterEach
    void tearDown() {
        // Rarely needed — Mockito resets mocks automatically
        // Use only for: temp files, system properties, static state
    }
}
```

> **WARNING: shared mutable state in unit tests is a bug magnet.**
> Prefer `@BeforeEach` / `@AfterEach` for anything mutable.
> `@BeforeAll` / `@AfterAll` is acceptable only for immutable or expensive shared fixtures that cannot leak state between tests.

### Integration Tests: @BeforeAll / @AfterAll Allowed

```java
@Testcontainers
@Tag("integration")
class OrderRepositoryIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
        .withDatabaseName("testdb")
        .withUsername("test")
        .withPassword("test");

    private static DataSource dataSource;
    private OrderRepository repository;

    @BeforeAll
    static void setUpInfrastructure() {
        // Expensive one-time setup: connection pool, migrations
        dataSource = DataSourceBuilder.create()
            .url(postgres.getJdbcUrl())
            .username(postgres.getUsername())
            .password(postgres.getPassword())
            .build();
        Flyway.configure().dataSource(dataSource).load().migrate();
    }

    @AfterAll
    static void tearDownInfrastructure() {
        // Container auto-cleaned by @Testcontainers
        // Close connection pool if needed
    }

    @BeforeEach
    void setUp() {
        // Per-test: clean state for isolation
        TestDatabaseHelper.truncateTables(dataSource, "orders", "order_items");
        repository = new JdbcOrderRepository(dataSource);
    }
}
```

---

## Integration Test Separation

Integration tests must have a dedicated execution path so unit tests stay fast.

### Naming Convention

| Type | Suffix | Runner |
|------|--------|--------|
| Unit test | `*Test.java` | Maven Surefire / `./gradlew test` |
| Integration test | `*IT.java` or tagged suite | Maven Failsafe / `./gradlew integrationTest` / tagged task |

### Gradle Configuration

```groovy
// build.gradle
sourceSets {
    integrationTest {
        java.srcDir 'src/integrationTest/java'
        resources.srcDir 'src/integrationTest/resources'
        compileClasspath += sourceSets.main.output + sourceSets.test.output
        runtimeClasspath += sourceSets.main.output + sourceSets.test.output
    }
}

configurations {
    integrationTestImplementation.extendsFrom testImplementation
    integrationTestRuntimeOnly.extendsFrom testRuntimeOnly
}

tasks.register('integrationTest', Test) {
    testClassesDirs = sourceSets.integrationTest.output.classesDirs
    classpath = sourceSets.integrationTest.runtimeClasspath
    shouldRunAfter test
}

check.dependsOn integrationTest
```

### Maven Configuration

```xml
<!-- pom.xml — maven-failsafe-plugin for integration tests -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-failsafe-plugin</artifactId>
    <executions>
        <execution>
            <goals>
                <goal>integration-test</goal>
                <goal>verify</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <includes>
            <include>**/*IT.java</include>
        </includes>
    </configuration>
</plugin>
```

---

## Testcontainers — Abstract Base Class

Share container setup across integration tests to avoid spinning up a new container per test class.

```java
// src/integrationTest/java/com/example/support/AbstractIntegrationTest.java
package com.example.support;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@SpringBootTest
@Testcontainers
@Tag("integration")
public abstract class AbstractIntegrationTest {

    @Container
    protected static PostgreSQLContainer<?> postgres =
        new PostgreSQLContainer<>("postgres:16-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }
}
```

```java
// Usage — extend the base class
class OrderRepositoryIT extends AbstractIntegrationTest {

    @Autowired
    private OrderRepository orderRepository;

    @BeforeEach
    void setUp() {
        // Clean state per test
        orderRepository.deleteAll();
    }

    @Test
    void savesAndFindsOrder() {
        Order saved = orderRepository.save(OrderTestFixtures.defaultOrder());
        Optional<Order> found = orderRepository.findById(saved.getId());

        assertThat(found).isPresent();
        assertThat(found.get().getStatus()).isEqualTo(OrderStatus.PENDING);
    }
}
```

---

## Cleanup Patterns

| Pattern | Scope | Use for |
|---------|-------|---------|
| `@AfterEach` | Per test | Reset in-memory state, clear test doubles |
| `@AfterAll` | Per class (integration only) | Close connection pools, stop containers |
| `truncateTables()` in `@BeforeEach` | Per test | Database isolation between integration tests |
| `@DirtiesContext` | Spring context | When test modifies Spring context (expensive — avoid if possible) |
| `@Testcontainers` + `@Container` | Auto-managed | Container lifecycle tied to test class |
| `deleteAll()` in `@BeforeEach` | Per test | JPA repository cleanup |

---

## When NOT to Create Shared Helpers

- Helper is used in only one test class — inline it
- Helper hides important test logic — keep it visible in the test
- Helper adds indirection without reducing duplication — skip it
- Over-abstracted builders make tests harder to read — keep it simple
- A simple `new Entity(...)` call is clearer than `EntityTestFixtures.default()` for trivial objects

---

## Related Skills

- `java-testing-patterns` - JUnit 5, Mockito, parameterized test patterns
- `java-test-engineer` - Comprehensive test review and coverage analysis
