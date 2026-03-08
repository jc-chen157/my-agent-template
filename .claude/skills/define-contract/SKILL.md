# Define Contract Skill

Turn an initial planning brief into a minimum viable contract packet before implementation starts.

## When to Use
- User says "define contracts" / "define interfaces" / "what are the boundaries?"
- User says "contract first" / "design the API" / "define the schema"
- After `initial-planning` has produced a planning brief
- The plan is clear at a high level, but types, interfaces, and behaviors are still implicit
- A task breakdown would be vague without clearer system promises

---

## Core Philosophy

Contracts are the implementation-facing expression of intent. They should define the smallest precise surface that lets another engineer or agent build confidently.

### Principles

| Principle | Meaning |
|-----------|---------|
| **Contracts before code** | Define what the system promises before deciding how to implement it |
| **Minimum viable contract** | Start with the smallest contract that captures the required behavior |
| **Behavior is first-class** | Signatures alone are not enough; define outcomes, failure modes, and side effects |
| **Assumptions are explicit** | If information is missing, propose the likely contract and label the assumption |
| **Block only on material uncertainty** | Stop only when a missing decision would change ownership, boundaries, or externally visible behavior |

### What Counts as Material Uncertainty

Block only if the missing information would change one of these:

- System boundary or component ownership
- Request or response shape exposed to another actor
- Source of truth for state
- Consistency or idempotency guarantees
- Security, tenant, or trust boundary

If the uncertainty is smaller than that, continue with a provisional contract and list the open question.

---

## Input Expectations

This skill works best on top of an `initial-planning` brief that already captures:

- Goal and success criteria
- Constraints and non-goals
- Known facts and assumptions
- Unknowns and proposed direction

If no planning brief exists, extract the best available high-level intent first and continue. Do not redirect into a generic architecture review.

---

## Workflow

## Step 1: Extract Domain Shapes

Identify the nouns and classify them by role:

- Entities with lifecycle or identity
- Value objects with validation rules
- Request and response structures
- Internal state structures that should not leak externally

Define only the fields needed for the current goal. Avoid speculative fields, framework details, and storage-specific naming.

## Step 2: Define Interfaces and Operations

Identify the verbs and group them by responsibility. Each interface should have one clear reason to exist.

For each interface, define:

- Interface ID and name
- Method IDs and signatures
- Inputs and outputs
- Named error outcomes
- Side effects that callers must know about

Use canonical IDs so later stages can refer to slices instead of copying whole sections:

- `entity.user`
- `value_object.email`
- `iface.user_service`
- `method.user_service.create`
- `flow.checkout`

## Step 3: Define Behavioral Contracts

For every method, specify:

- Preconditions
- Postconditions
- Failure modes
- Idempotency behavior when relevant
- Observable side effects

If state changes over time, define legal and illegal transitions explicitly. If a flow crosses multiple steps or actors, define the sequence and failure points.

## Step 4: Turn Gaps into Assumptions or Open Questions

Do not stop at the first missing detail. Instead:

1. Propose the minimum viable contract
2. Record the assumption that made it possible
3. Record any open question that still matters
4. Mark the packet as blocked only if a material uncertainty remains

### Good vs Bad Gap Handling

```text
Bad:
- "The cache strategy is unclear, so I cannot define the service contract."

Better:
- "Assumption: the cache is an internal optimization and not part of the external contract."
- "Open question: is cache invalidation synchronous or eventual?"
- "Status: ready_with_assumptions"
```

---

## Contract Quality Rules

- Separate external requests/responses from internal state
- Prefer concrete value objects over vague primitive bags
- Name every externally meaningful error case
- Avoid technology-coupled interface names
- Keep responsibilities narrow
- Prefer concrete contracts over premature generic abstractions
- Make tenant, auth, and idempotency semantics explicit when relevant

---

## Public Output Contract

Return a markdown packet with a compact structured block that later skills can consume.

````markdown
# Contract Packet: [Feature or Module Name]

## Entities
- `entity.user`: purpose, fields, invariants

## Value Objects
- `value_object.email`: format and validation rules

## Interfaces
- `iface.user_service`
  - `method.user_service.create(request: CreateUserRequest): CreateUserResponse`

## Behaviors
- `method.user_service.create`
  - Preconditions: ...
  - Postconditions: ...
  - Errors: ...
  - Side effects: ...

## State Transitions
- `entity.order`: PENDING -> CONFIRMED -> SHIPPED

## Flow Contracts
- `flow.checkout`: sequence, idempotency, failure points

## Acceptance Scenarios
- Scenario 1: ...
- Scenario 2: ...

## Open Questions
- ...

## Readiness
- Status: `ready` | `ready_with_assumptions` | `blocked`
- Blocking reason: `none` or specific material uncertainty

```yaml
entities:
  - id: entity.user
    name: User
    purpose: Represents an application user
value_objects:
  - id: value_object.email
    name: Email
interfaces:
  - id: iface.user_service
    methods:
      - id: method.user_service.create
behaviors:
  - contract_id: method.user_service.create
state_transitions: []
flow_contracts: []
acceptance_scenarios:
  - id: scenario.user.create.success
open_questions: []
readiness: ready_with_assumptions
```
````

---

## Validation Checklist

- [ ] Every important noun in the plan is represented as an entity, value object, request, response, or internal state shape
- [ ] Every important verb is represented as an interface method or flow contract
- [ ] Every method has preconditions, postconditions, and named error outcomes
- [ ] State transitions are explicit where lifecycle matters
- [ ] Acceptance scenarios are rich enough for later validation
- [ ] Assumptions and open questions are separated clearly
- [ ] The packet is blocked only if the remaining uncertainty is material

---

## Related Skills

- `initial-planning` - Produce the planning brief that feeds this contract packet
- `break-down-plan` - Turn this contract packet into a task DAG
- `validate-against-contract` - Check completed work against this packet
