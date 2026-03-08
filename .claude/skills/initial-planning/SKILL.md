# Initial Planning Skill

Turn a vague or high-level request into a verbose planning brief before defining contracts or tasks.

## When to Use
- User starts with a rough direction, brainstorm, or speech-to-text dump
- The request has intent but not enough structure for interfaces or task breakdown
- User says "plan this" / "help me think through this" / "what are we actually building?"
- Before `define-contract`
- The fastest way forward is to gather and normalize context, then prune later

---

## Core Philosophy

Initial planning is the most important stage of the workflow. At this point, bias toward collecting more context than you need. Deleting excess detail later is easier than inventing missing detail during implementation.

### Principles

| Principle | Meaning |
|-----------|---------|
| **Verbose first** | Capture the raw problem space before trying to compress it |
| **Deletion over addition** | Over-collect now so later stages can prune confidently |
| **Intent before interfaces** | Understand goals and success criteria before defining contracts |
| **Assume carefully** | Prefer explicit assumptions to premature blocking |
| **Do not jump to tasks** | This stage produces a planning brief, not an implementation plan |

---

## Workflow

## Step 1: Capture Raw Intent

Extract the high-level ask in plain language:

- What outcome does the user want?
- Who benefits from the result?
- What pain or friction is motivating the work?
- What is definitely in scope already?

Preserve ambiguity instead of flattening it too early.

## Step 2: Expand the Missing Dimensions

Turn the raw request into a fuller brief by filling in the dimensions below:

- Success criteria
- Constraints and fixed requirements
- Existing system or process context
- Dependencies and integrations
- Known facts from the prompt or environment
- Assumptions needed to move forward
- Unknowns that still matter
- Non-goals and things explicitly out of scope

Use reasonable assumptions when they reduce noise without changing the direction materially.

## Step 3: Propose a Working Interpretation

Synthesize the information into a proposed direction:

- What problem is actually being solved?
- What shape of solution seems most consistent with the request?
- What must be true for the next stage to succeed?

Do not define interfaces yet. Stay one level higher.

## Step 4: Decide Readiness for Contract Work

Mark the brief as one of:

- `ready`: enough information exists to define contracts directly
- `ready_with_assumptions`: contract work can continue if assumptions are carried forward
- `blocked`: a missing decision would materially change the contract or scope

Only choose `blocked` when the missing information changes success criteria, boundaries, or ownership.

---

## Questioning Rules

Ask the user only after exhausting reasonable assumptions.

Ask only if the answer would materially change:

- The goal
- Success criteria
- Scope boundaries
- External interfaces
- Ownership or source of truth

If the unknown is smaller than that, continue and record it as an assumption or open question.

---

## Good vs Bad Initial Planning

```text
Input:
"Build a planning harness for multi-agent backend work."

Bad output:
- "We should define APIs and create tasks for the orchestrator."

Why bad:
- Jumps straight to solutioning
- No success criteria
- No constraints
- No explicit assumptions

Better output:
- Goal: create a reusable planning workflow for agent-driven backend work
- Success criteria: vague prompts become structured briefs, contracts, and task packets
- Constraints: skill-based, markdown-only, predictable prompt chaining
- Assumptions: focus on planning artifacts before runtime orchestration
- Unknowns: whether parallel execution is default or exceptional
- Proposed direction: a staged harness with discovery, contracting, decomposition, and validation
```

---

## Public Output Contract

Return a markdown brief with a compact structured block.

````markdown
# Initial Planning Brief: [Feature or Initiative Name]

## Raw Direction
[What the user said or implied]

## Interpreted Goal
[What problem should be solved]

## Success Criteria
- ...

## Constraints
- ...

## Known Facts
- ...

## Assumptions
- ...

## Unknowns
- ...

## Non-Goals
- ...

## Proposed Direction
[One short paragraph]

## Readiness for Contract
- Status: `ready` | `ready_with_assumptions` | `blocked`
- Why: ...

```yaml
goal: Build a planning harness for multi-agent backend work
success_criteria:
  - Vague prompts become structured planning artifacts
constraints:
  - Markdown-only skills
assumptions:
  - Planning artifacts are the first deliverable
unknowns:
  - Whether execution orchestration is in scope
readiness_for_contract: ready_with_assumptions
```
````

---

## Validation Checklist

- [ ] The brief captures the user goal in plain language
- [ ] Success criteria are concrete enough to evaluate later
- [ ] Constraints and non-goals are explicit
- [ ] Known facts are separated from assumptions
- [ ] Unknowns are recorded without blocking progress unnecessarily
- [ ] A proposed direction is included
- [ ] Readiness for contract work is stated clearly

---

## Related Skills

- `define-contract` - Turn this brief into explicit system promises
- `break-down-plan` - Split the contract packet into executable tasks
- `validate-against-contract` - Evaluate delivered work against the agreed contracts
