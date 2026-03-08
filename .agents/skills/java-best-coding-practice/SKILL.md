# Java Best Coding Practice Skill

Comprehensive Java code quality skill combining SOLID principles, design patterns, and clean code practices.

## When to Use
- User says "review my Java code" / "check code quality" / "refactor this"
- User says "check SOLID" / "SOLID review" / "is this class doing too much?"
- User asks to implement or apply a design pattern
- User says "clean this code" / "improve readability" / "reduce complexity"
- Code review focusing on design, maintainability, or best practices
- Refactoring large or rigid classes
- Designing extensible or flexible components

---

## Part 1: SOLID Principles

### Quick Reference

| Letter | Principle | One-liner |
|--------|-----------|-----------|
| **S** | Single Responsibility | One class = one reason to change |
| **O** | Open/Closed | Open for extension, closed for modification |
| **L** | Liskov Substitution | Subtypes must be substitutable for base types |
| **I** | Interface Segregation | Many specific interfaces > one general interface |
| **D** | Dependency Inversion | Depend on abstractions, not concretions |

---

### S - Single Responsibility Principle (SRP)

> "A class should have only one reason to change."

#### Violation

```java
// ❌ BAD: UserService does too much
public class UserService {
    public User createUser(String name, String email) {
        // validation logic
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Invalid email");
        }
        // persistence logic
        User user = new User(name, email);
        entityManager.persist(user);
        // notification logic
        emailClient.send(email, "Welcome!", "Hello " + name);
        // audit logic
        auditLog.log("User created: " + email);
        return user;
    }
}
```

#### Refactored

```java
// ✅ GOOD: Each class has one responsibility
public class UserValidator {
    public void validate(String name, String email) {
        if (email == null || !email.contains("@")) {
            throw new ValidationException("Invalid email");
        }
    }
}

public class UserRepository {
    public User save(User user) {
        entityManager.persist(user);
        return user;
    }
}

public class WelcomeEmailSender {
    public void sendWelcome(User user) {
        emailClient.send(user.getEmail(), "Welcome!", "Hello " + user.getName());
    }
}

public class UserService {
    private final UserValidator validator;
    private final UserRepository repository;
    private final WelcomeEmailSender emailSender;

    public User createUser(String name, String email) {
        validator.validate(name, email);
        User user = repository.save(new User(name, email));
        emailSender.sendWelcome(user);
        return user;
    }
}
```

#### How to Detect SRP Violations

- Class has many `import` statements from different domains
- Class name contains "And", "Manager", or "Handler" (often)
- Methods operate on unrelated data
- Changes in one area require touching unrelated methods
- Cannot describe the class purpose in one sentence without "and"

---

### O - Open/Closed Principle (OCP)

> "Open for extension, closed for modification."

#### Violation

```java
// ❌ BAD: Must modify class to add new discount type
public class DiscountCalculator {
    public double calculate(Order order, String discountType) {
        if (discountType.equals("PERCENTAGE")) {
            return order.getTotal() * 0.1;
        } else if (discountType.equals("FIXED")) {
            return 50.0;
        }
        // Every new discount type = modify this class
        return 0;
    }
}
```

#### Refactored

```java
// ✅ GOOD: Add new discounts without modifying existing code
public interface DiscountStrategy {
    double calculate(Order order);
    boolean supports(String discountType);
}

public class PercentageDiscount implements DiscountStrategy {
    @Override
    public double calculate(Order order) { return order.getTotal() * 0.1; }
    @Override
    public boolean supports(String type) { return "PERCENTAGE".equals(type); }
}

public class DiscountCalculator {
    private final List<DiscountStrategy> strategies;

    public DiscountCalculator(List<DiscountStrategy> strategies) {
        this.strategies = strategies;
    }

    public double calculate(Order order, String discountType) {
        return strategies.stream()
            .filter(s -> s.supports(discountType))
            .findFirst()
            .map(s -> s.calculate(order))
            .orElse(0.0);
    }
}
```

#### How to Detect OCP Violations

- `if/else` or `switch` on type/status that grows over time
- Enum-based dispatching with frequent new values
- Changes require modifying core classes

---

### L - Liskov Substitution Principle (LSP)

> "Subtypes must be substitutable for their base types."

#### Violation

```java
// ❌ BAD: Square violates Rectangle contract
public class Square extends Rectangle {
    @Override
    public void setWidth(int width) {
        this.width = width;
        this.height = width;  // Violates expected behavior!
    }
}
```

#### Refactored

```java
// ✅ GOOD: Separate abstractions
public interface Shape {
    int getArea();
}

public class Rectangle implements Shape {
    private final int width, height;
    public Rectangle(int width, int height) { this.width = width; this.height = height; }
    @Override public int getArea() { return width * height; }
}

public class Square implements Shape {
    private final int side;
    public Square(int side) { this.side = side; }
    @Override public int getArea() { return side * side; }
}
```

#### LSP Rules

| Rule | Meaning |
|------|---------|
| Preconditions | Subclass cannot strengthen (require more) |
| Postconditions | Subclass cannot weaken (promise less) |
| Invariants | Subclass must maintain parent's invariants |
| History | Subclass cannot modify inherited state unexpectedly |

#### How to Detect LSP Violations

- Subclass throws exceptions parent doesn't
- Subclass returns null where parent returns object
- `instanceof` checks before calling methods
- Empty or throwing implementations of interface methods

---

### I - Interface Segregation Principle (ISP)

> "Clients should not be forced to depend on interfaces they do not use."

#### Violation

```java
// ❌ BAD: Fat interface forces unnecessary implementations
public interface Worker {
    void work();
    void eat();
    void sleep();
    void attendMeeting();
}

public class Robot implements Worker {
    @Override public void work() { /* OK */ }
    @Override public void eat() { /* Can't eat! */ }
    @Override public void sleep() { /* Can't sleep! */ }
    @Override public void attendMeeting() { /* OK */ }
}
```

#### Refactored

```java
// ✅ GOOD: Segregated interfaces
public interface Workable { void work(); }
public interface Feedable { void eat(); void sleep(); }
public interface Manageable { void attendMeeting(); }

public class Employee implements Workable, Feedable, Manageable { /* all methods */ }
public class Robot implements Workable { /* only work() */ }
public class Intern implements Workable, Feedable { /* work + eat/sleep */ }
```

#### How to Detect ISP Violations

- Implementations with empty methods or `throw new UnsupportedOperationException()`
- Interface has 10+ methods
- Different clients use completely different subsets of methods

---

### D - Dependency Inversion Principle (DIP)

> "High-level modules should not depend on low-level modules. Both should depend on abstractions."

#### Violation

```java
// ❌ BAD: High-level depends on low-level directly
public class OrderService {
    private MySqlOrderRepository repository;  // Concrete class!
    private SmtpEmailSender emailSender;      // Concrete class!

    public OrderService() {
        this.repository = new MySqlOrderRepository();  // Hard dependency
        this.emailSender = new SmtpEmailSender();
    }
}
```

#### Refactored

```java
// ✅ GOOD: Depend on abstractions
public interface OrderRepository {
    void save(Order order);
    Optional<Order> findById(Long id);
}

public interface NotificationSender {
    void send(String recipient, String message);
}

public class OrderService {
    private final OrderRepository repository;
    private final NotificationSender notificationSender;

    // Dependencies injected via constructor
    public OrderService(OrderRepository repository, NotificationSender sender) {
        this.repository = repository;
        this.notificationSender = sender;
    }
}
```

#### DIP with Spring

```java
@Service
public class OrderService {
    private final OrderRepository repository;
    private final NotificationSender notificationSender;

    // Constructor injection (recommended)
    public OrderService(OrderRepository repository, NotificationSender sender) {
        this.repository = repository;
        this.notificationSender = sender;
    }
}

@Repository
public class JpaOrderRepository implements OrderRepository { }

@Component
@Profile("production")
public class SmtpEmailSender implements NotificationSender { }

@Component
@Profile("test")
public class MockEmailSender implements NotificationSender { }
```

#### How to Detect DIP Violations

- `new ConcreteClass()` inside business logic
- Import statements include implementation packages (e.g., `com.mysql`, `org.apache.http`)
- Cannot easily swap implementations
- Tests require real infrastructure (database, network)

---

### SOLID Review Checklist

| Principle | Question |
|-----------|----------|
| **SRP** | Does this class have more than one reason to change? |
| **OCP** | Will adding a new type/feature require modifying this class? |
| **LSP** | Can subclasses be used wherever parent is expected? |
| **ISP** | Are there empty or throwing method implementations? |
| **DIP** | Does high-level code depend on concrete implementations? |

### Common SOLID Refactoring Patterns

| Violation | Refactoring |
|-----------|-------------|
| SRP - God class | Extract Class, Move Method |
| OCP - Type switching | Strategy Pattern, Factory |
| LSP - Broken inheritance | Composition over Inheritance, Extract Interface |
| ISP - Fat interface | Split Interface, Role Interface |
| DIP - Hard dependencies | Dependency Injection, Abstract Factory |

---

## Part 2: Design Patterns

### Pattern Selection Guide

| Problem | Pattern |
|---------|---------|
| Complex object construction | **Builder** |
| Create objects without specifying class | **Factory** |
| Multiple algorithms, swap at runtime | **Strategy** |
| Add behavior without changing class | **Decorator** |
| Notify multiple objects of changes | **Observer** |
| Ensure single instance | **Singleton** |
| Convert incompatible interfaces | **Adapter** |
| Define algorithm skeleton | **Template Method** |

---

### Creational Patterns

#### Builder

**Use when:** Object has many parameters, some optional.

```java
// ❌ Telescoping constructor antipattern
public User(String name) { }
public User(String name, String email) { }
public User(String name, String email, int age) { }

// ✅ Builder pattern
public class User {
    private final String name;
    private final String email;
    private final int age;
    private final String phone;

    private User(Builder builder) {
        this.name = builder.name;
        this.email = builder.email;
        this.age = builder.age;
        this.phone = builder.phone;
    }

    public static Builder builder(String name, String email) {
        return new Builder(name, email);
    }

    public static class Builder {
        private final String name;
        private final String email;
        private int age = 0;
        private String phone = "";

        private Builder(String name, String email) {
            this.name = name;
            this.email = email;
        }

        public Builder age(int age) { this.age = age; return this; }
        public Builder phone(String phone) { this.phone = phone; return this; }
        public User build() { return new User(this); }
    }
}

// Usage
User user = User.builder("John", "john@example.com").age(30).build();
```

**With Lombok:** `@Builder @Getter public class User { ... }`

---

#### Factory Method

**Use when:** Need to create objects without specifying exact class.

```java
public interface Notification { void send(String message); }

public class NotificationFactory {
    public static Notification create(String type) {
        return switch (type.toUpperCase()) {
            case "EMAIL" -> new EmailNotification();
            case "SMS" -> new SmsNotification();
            case "PUSH" -> new PushNotification();
            default -> throw new IllegalArgumentException("Unknown type: " + type);
        };
    }
}
```

**With Spring (preferred):**

```java
@Component
public class NotificationFactory {
    private final Map<String, NotificationSender> senders;

    public NotificationFactory(List<NotificationSender> senderList) {
        this.senders = senderList.stream()
            .collect(Collectors.toMap(NotificationSender::getType, Function.identity()));
    }

    public NotificationSender getSender(String type) {
        return Optional.ofNullable(senders.get(type))
            .orElseThrow(() -> new IllegalArgumentException("Unknown: " + type));
    }
}
```

---

#### Singleton

**Use when:** Exactly one instance needed (use sparingly!).

```java
// ✅ Enum-based singleton (thread-safe)
public enum DatabaseConnection {
    INSTANCE;
    private Connection connection;
    public Connection getConnection() { return connection; }
}
```

**Prefer Spring `@Component` (default singleton scope) over manual singletons.**

**Warning:** Singletons are hard to test (global state) and create hidden dependencies.

---

### Behavioral Patterns

#### Strategy

**Use when:** Multiple algorithms for same operation, need to swap at runtime.

```java
public interface PaymentStrategy {
    void pay(BigDecimal amount);
}

public class CreditCardPayment implements PaymentStrategy {
    private final String cardNumber;
    public CreditCardPayment(String cardNumber) { this.cardNumber = cardNumber; }
    @Override public void pay(BigDecimal amount) { /* charge card */ }
}

public class PayPalPayment implements PaymentStrategy {
    private final String email;
    public PayPalPayment(String email) { this.email = email; }
    @Override public void pay(BigDecimal amount) { /* PayPal payment */ }
}

// Context
public class ShoppingCart {
    private PaymentStrategy paymentStrategy;
    public void setPaymentStrategy(PaymentStrategy strategy) { this.paymentStrategy = strategy; }
    public void checkout(BigDecimal total) { paymentStrategy.pay(total); }
}
```

**With Java 8+ lambdas:** Use `@FunctionalInterface` and pass lambdas directly.

---

#### Observer

**Use when:** Objects need to be notified of changes in another object.

```java
public interface OrderObserver {
    void onOrderPlaced(Order order);
}

public class OrderService {
    private final List<OrderObserver> observers = new ArrayList<>();
    public void addObserver(OrderObserver observer) { observers.add(observer); }

    public void placeOrder(Order order) {
        saveOrder(order);
        observers.forEach(o -> o.onOrderPlaced(order));
    }
}
```

**With Spring Events (preferred):**

```java
public record OrderPlacedEvent(Order order) {}

@Service
public class OrderService {
    private final ApplicationEventPublisher eventPublisher;
    public void placeOrder(Order order) {
        saveOrder(order);
        eventPublisher.publishEvent(new OrderPlacedEvent(order));
    }
}

@Component
public class InventoryListener {
    @EventListener
    public void handleOrderPlaced(OrderPlacedEvent event) { /* reduce inventory */ }
}
```

---

#### Template Method

**Use when:** Define algorithm skeleton, let subclasses fill in steps.

```java
public abstract class DataProcessor {
    // Template method - defines the algorithm
    public final void process() {
        readData();
        processData();
        writeData();
        if (shouldNotify()) { notifyCompletion(); }
    }

    protected abstract void readData();
    protected abstract void processData();
    protected abstract void writeData();
    protected boolean shouldNotify() { return true; }  // Hook
    protected void notifyCompletion() { System.out.println("Done!"); }
}

public class CsvDataProcessor extends DataProcessor {
    @Override protected void readData() { /* read CSV */ }
    @Override protected void processData() { /* process CSV */ }
    @Override protected void writeData() { /* write to DB */ }
}
```

---

### Structural Patterns

#### Decorator

**Use when:** Add behavior dynamically without modifying existing classes.

```java
public interface Coffee {
    String getDescription();
    BigDecimal getCost();
}

public class SimpleCoffee implements Coffee {
    @Override public String getDescription() { return "Coffee"; }
    @Override public BigDecimal getCost() { return new BigDecimal("2.00"); }
}

public abstract class CoffeeDecorator implements Coffee {
    protected final Coffee coffee;
    public CoffeeDecorator(Coffee coffee) { this.coffee = coffee; }
}

public class MilkDecorator extends CoffeeDecorator {
    public MilkDecorator(Coffee coffee) { super(coffee); }
    @Override public String getDescription() { return coffee.getDescription() + ", Milk"; }
    @Override public BigDecimal getCost() { return coffee.getCost().add(new BigDecimal("0.50")); }
}

// Usage: compose decorators
Coffee coffee = new MilkDecorator(new SimpleCoffee());
```

---

#### Adapter

**Use when:** Make incompatible interfaces work together.

```java
public interface MediaPlayer { void play(String filename); }

// Legacy third-party class
public class LegacyAudioPlayer {
    public void playMp3(String filename) { /* ... */ }
}

// Adapter
public class Mp3PlayerAdapter implements MediaPlayer {
    private final LegacyAudioPlayer legacyPlayer = new LegacyAudioPlayer();
    @Override public void play(String filename) { legacyPlayer.playMp3(filename); }
}
```

---

### Anti-Patterns to Avoid

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Singleton abuse | Global state, hard to test | Dependency Injection |
| Factory everywhere | Over-engineering | Simple `new` if type is known |
| Deep decorator chains | Hard to debug | Keep chains short |
| Observer with many events | Spaghetti notifications | Event bus, clear event hierarchy |

---

## Part 3: Clean Code Principles

### Core Principles

| Principle | Meaning | Violation Sign |
|-----------|---------|----------------|
| **DRY** | Don't Repeat Yourself | Copy-pasted code blocks |
| **KISS** | Keep It Simple, Stupid | Over-engineered solutions |
| **YAGNI** | You Aren't Gonna Need It | Features "just in case" |

---

### DRY - Don't Repeat Yourself

```java
// ❌ BAD: Same validation repeated
public void createUser(UserRequest req) {
    if (req.getEmail() == null || !req.getEmail().contains("@"))
        throw new ValidationException("Invalid email");
    // ...
}
public void updateUser(UserRequest req) {
    if (req.getEmail() == null || !req.getEmail().contains("@"))
        throw new ValidationException("Invalid email");
    // ...
}

// ✅ GOOD: Single source of truth
public class EmailValidator {
    public void validate(String email) {
        if (email == null || !email.contains("@"))
            throw new ValidationException("Invalid email");
    }
}
```

**DRY Exception:** Not all duplication is bad — avoid premature abstraction when code looks similar but serves different purposes and will evolve independently.

---

### KISS - Keep It Simple

```java
// ❌ BAD: Over-engineered
public boolean isEmpty(String str) {
    return Optional.ofNullable(str)
        .map(String::trim)
        .map(String::isEmpty)
        .orElseGet(() -> Boolean.TRUE);
}

// ✅ GOOD: Simple and clear
public boolean isEmpty(String str) {
    return str == null || str.isBlank();  // Java 11+
}
```

---

### YAGNI - You Aren't Gonna Need It

```java
// ❌ BAD: 20+ repository methods "just in case"
public interface Repository<T, ID> {
    T findById(ID id); List<T> findAll(); T save(T entity);
    void delete(T entity); void deleteById(ID id); long count(); // ...
}

// ✅ GOOD: Only what's needed now
public interface UserRepository {
    Optional<User> findById(Long id);
    User save(User user);
}
```

---

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Class | PascalCase, noun | `OrderService` |
| Interface | PascalCase, adjective/noun | `Comparable`, `List` |
| Method | camelCase, verb | `calculateTotal()` |
| Variable | camelCase, noun | `customerEmail` |
| Constant | UPPER_SNAKE | `MAX_RETRY_COUNT` |
| Package | lowercase | `com.example.orders` |
| Boolean | is/has/can/should prefix | `isActive`, `hasPermission` |

```java
// ❌ BAD
int d; String s; void process(); class Manager { }

// ✅ GOOD
int elapsedTimeInDays; String customerName; void processPayment(); class PaymentGateway { }
```

---

### Functions / Methods

#### Keep Functions Small

```java
// ❌ BAD: 50+ line method
public void processOrder(Order order) {
    // validate (10 lines) + calculate (15 lines) + notify (10 lines) ...
}

// ✅ GOOD: Small, focused methods
public void processOrder(Order order) {
    validateOrder(order);
    calculateTotals(order);
    applyDiscounts(order);
    updateInventory(order);
    sendNotifications(order);
}
```

#### Single Level of Abstraction

```java
// ❌ BAD: Mixed abstraction levels
public void processOrder(Order order) {
    validateOrder(order);  // High level
    BigDecimal total = BigDecimal.ZERO;  // Low level detail mixed in
    for (OrderItem item : order.getItems()) {
        total = total.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
    }
    sendEmail(order);  // High level again
}

// ✅ GOOD: Consistent abstraction level
public void processOrder(Order order) {
    validateOrder(order);
    calculateTotal(order);
    sendConfirmation(order);
}
```

#### Limit Parameters (max 3)

```java
// ❌ BAD: Too many parameters
public User createUser(String firstName, String lastName, String email,
                       String phone, String address, String city) { }

// ✅ GOOD: Use parameter object
public User createUser(CreateUserRequest request) { }
```

#### Avoid Flag Arguments

```java
// ❌ BAD
public void sendMessage(String message, boolean isUrgent) { }

// ✅ GOOD: Separate methods
public void sendUrgentMessage(String message) { }
public void queueMessage(String message) { }
```

---

### Guard Clauses

```java
// ❌ BAD: Deeply nested
public void processOrder(Order order) {
    if (order != null) {
        if (order.isValid()) {
            if (order.hasItems()) {
                // actual logic buried here
            }
        }
    }
}

// ✅ GOOD: Guard clauses (early return)
public void processOrder(Order order) {
    if (order == null) return;
    if (!order.isValid()) return;
    if (!order.hasItems()) return;

    // actual logic at top level
}
```

---

### Comments

```java
// ❌ BAD: Noise comments
user.setName(name);  // Set the user's name
counter++;           // Increment counter

// ✅ GOOD: Explain WHY, not WHAT
// Retry with exponential backoff to avoid overwhelming the server
// during high load periods (see incident #1234)
for (int attempt = 0; attempt < MAX_RETRIES; attempt++) {
    Thread.sleep((long) Math.pow(2, attempt) * 1000);
}

// ✅ GOOD: Let code speak instead of commenting
// ❌ if ((user.getRole() == 1 || user.getRole() == 2) && (action == 3 || action == 7))
// ✅
if (user.hasAdminPrivileges() && action.isAllowedFor(user.getRole())) { }
```

---

### Common Code Smells

| Smell | Description | Fix |
|-------|-------------|-----|
| **Long Method** | Method > 20 lines | Extract Method |
| **Long Parameter List** | > 3 parameters | Parameter Object |
| **Duplicate Code** | Same code in multiple places | Extract Method/Class |
| **Dead Code** | Unused code | Delete it |
| **Magic Numbers** | Unexplained literals | Named Constants |
| **God Class** | Class doing too much | Extract Class |
| **Feature Envy** | Method uses another class's data | Move Method |
| **Primitive Obsession** | Primitives instead of objects | Value Objects |

#### Magic Numbers

```java
// ❌ BAD
if (user.getAge() >= 18) { }
Thread.sleep(86400000);

// ✅ GOOD
private static final int ADULT_AGE = 18;
private static final long ONE_DAY_MS = TimeUnit.DAYS.toMillis(1);
if (user.getAge() >= ADULT_AGE) { }
Thread.sleep(ONE_DAY_MS);
```

#### Primitive Obsession

```java
// ❌ BAD: Easy to mix up parameters
createUser("12345", "john@email.com", "555-1234");  // Wrong order, compiles!

// ✅ GOOD: Value objects with self-validation
public record Email(String value) {
    public Email {
        if (!value.contains("@")) throw new IllegalArgumentException("Invalid email");
    }
}

public void createUser(Email email, PhoneNumber phone, ZipCode zipCode) { }
```

---

## Comprehensive Review Checklist

### SOLID Principles
- [ ] Does each class have only one reason to change? (SRP)
- [ ] Can new types/features be added without modifying existing classes? (OCP)
- [ ] Can subclasses be used wherever parent type is expected? (LSP)
- [ ] Are interfaces focused and specific to client needs? (ISP)
- [ ] Does high-level code depend on abstractions, not concretions? (DIP)

### Design Patterns
- [ ] Are appropriate patterns used for the problem at hand?
- [ ] Are patterns not over-applied (no pattern for pattern's sake)?
- [ ] Is dependency injection used instead of manual singletons?

### Clean Code
- [ ] Are names meaningful, pronounceable, and consistent?
- [ ] Are functions small and focused (< 20 lines)?
- [ ] Is there any duplicated code?
- [ ] Are there magic numbers or strings?
- [ ] Do comments explain "why" not "what"?
- [ ] Is the code at consistent abstraction level?
- [ ] Is there dead/unused code?
- [ ] Are guard clauses used instead of deep nesting?
- [ ] Are parameters limited (max 3, use objects otherwise)?
