# Break Down Plan Skill

Turn a contract packet into a decision-complete task DAG for implementation.

## When to Use
- User says "break down the plan" / "create tasks" / "decompose this"
- A contract packet already exists and implementation should be staged
- The work is too large for one focused execution pass
- User asks what can run in parallel and what must stay serialized
- Multiple agents may be used, but only if independence is explicit

---

## Core Philosophy

Decomposition is a tool, not a default. Start from a single-agent path and split only when the work units are genuinely independent. Parallelism is earned by clear inputs, outputs, and touched surfaces.

### Principles

| Principle | Meaning |
|-----------|---------|
| **Serial by default** | Assume one execution lane until independence is proven |
| **Decompose as needed** | Split only when a task is too large or mixes unrelated concerns |
| **Contract slices, not full copies** | Embed only the relevant contract IDs and supporting excerpt for each task |
| **Dependency-aware** | Every task must declare what it needs and what it produces |
| **Merge points are explicit** | Shared files, wiring, config, and integration work are serialized unless a merge strategy is defined |

---

## Workflow

## Step 1: Map Contracts to Work Units

Start from the contract packet and identify the smallest useful implementation units:

- Data structures and schemas
- Interface implementations
- External boundary adapters
- Cross-cutting foundation work
- Integration and wiring

Prefer one cohesive responsibility per task. If a task still mixes unrelated concerns, split it further.

## Step 2: Identify Touched Surfaces

For each candidate task, record the surfaces it will modify or depend on:

- Modules or packages
- Files or file groups
- Shared configuration
- Wiring or dependency composition
- Database schema or migrations

These touched surfaces determine whether work can truly run in parallel.

## Step 3: Build the Dependency Graph

For every task, define:

- Required inputs
- Produced outputs
- Upstream task dependencies
- Downstream consumers
- Merge points

If two tasks touch the same mutable surface, they are not independent unless the merge strategy is explicit and low-risk.

## Step 4: Decide Serial vs Parallel

Parallelize only when all of the following are true:

- Inputs are already available
- Outputs do not conflict
- Touched surfaces are independent
- The acceptance checks can be evaluated separately
- The merge cost is lower than the coordination cost

If any of these fail, keep the work serialized.

### Default Serialized Work

Treat these as serialized unless the contract packet says otherwise:

- Dependency injection and wiring
- Shared config or env loading
- Shared error infrastructure
- Migrations that affect the same schema area
- Integration tasks that combine multiple components

## Step 5: Produce the Task Packet

Each task must be self-contained enough that an agent can execute it without guessing. Embed the relevant contract slice and reference the canonical contract IDs instead of pasting the entire contract packet.

---

## Task Shape

Each task should include:

- `task_id`
- `title`
- `depends_on`
- `parallel_group`
- `inputs`
- `outputs`
- `acceptance_checks`
- `touched_surfaces`
- `merge_points`

### Good vs Bad Task Framing

```text
Bad:
Task: "Implement user module"

Why bad:
- Too large
- No dependency shape
- No touched surfaces
- No clear acceptance checks

Better:
Task ID: T03
Title: Implement `iface.user_service`
Depends on: T01, T02
Inputs: `entity.user`, `method.user_service.create`
Outputs: service implementation and service tests
Touched surfaces: `src/user/service.*`
Merge points: none
Acceptance checks:
- create returns the contracted response
- duplicate email returns the named contract error
```

---

## Public Output Contract

Return a markdown task packet with an embedded DAG summary.

````markdown
# Task Packet: [Feature or Module Name]

## Execution Strategy
- Default lane: `serial`
- Parallel lanes used: `0` or explicit groups
- Reasoning: ...

## Dependency Graph
[ASCII DAG or concise phase list]

## Tasks

### Task T01: [Title]
- Depends on: none
- Parallel group: none
- Contract IDs:
  - `entity.user`
  - `method.user_service.create`

#### Contract Slice
[Only the relevant excerpt needed for this task]

#### Inputs
- ...

#### Outputs
- ...

#### Acceptance Checks
- ...

#### Touched Surfaces
- ...

#### Merge Points
- none

```yaml
tasks:
  - task_id: T01
    title: Define user data structures
    depends_on: []
    parallel_group: null
    inputs:
      - entity.user
    outputs:
      - src/domain/user.go
    acceptance_checks:
      - User fields match the contract packet
    touched_surfaces:
      - src/domain/user.go
    merge_points: []
```
````

---

## Parallelism Rules

| Situation | Parallel? | Rule |
|-----------|-----------|------|
| Different modules, different files, no shared wiring | Yes | Safe candidate for separate lanes |
| Same interface, split by unrelated methods with separate files and tests | Maybe | Only if touched surfaces and merge points are explicit |
| Shared file or shared schema area | No | Serialize or add an explicit merge task |
| Wiring, config, or integration | No by default | Serialize unless a clear merge strategy exists |
| Test-only task for unrelated module | Yes | Safe if it does not overlap touched surfaces |

---

## Validation Checklist

- [ ] Every important contract ID is covered by at least one task
- [ ] Every task has explicit dependencies and outputs
- [ ] Every task includes acceptance checks
- [ ] Every task records touched surfaces
- [ ] Shared-file and integration work is serialized or has an explicit merge strategy
- [ ] Parallel lanes exist only where independence is proven
- [ ] The packet is small enough to execute one task at a time without losing context

---

## Related Skills

- `initial-planning` - Produce the planning brief before contracts exist
- `define-contract` - Produce the contract packet this skill decomposes
- `validate-against-contract` - Evaluate completed work against the contract and task packets
