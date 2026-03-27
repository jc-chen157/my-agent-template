# Planning Protocol

This document is the canonical planning workflow contract for this repository.

It defines:
- planning phases
- internal review loops
- user gates
- canonical planning artifacts
- artifact storage rules
- traceability rules
- task sizing guardrails
- planner-to-executor handoff rules

## Purpose

The planning system should be:
- human-readable first
- artifact-driven rather than conversationally implied
- explicit about assumptions, risks, and tradeoffs
- strict enough that downstream execution does not guess
- small enough that the workflow remains usable

## Core Principle

Planning is not complete when the work is merely described.

Planning is complete only when:
- the problem has been understood and challenged
- the proposed solution has been defended against objections
- the work has been decomposed into executable tasks
- the user has approved the current artifact at each required gate

## Source Of Truth

Use these rules when planning:
- `.claude/planning/protocol.md` is the canonical planning protocol
- `.claude/agents/master-planner.md` is the only planning orchestrator for the entire planning lifecycle
- `.claude/skills/planning-*.md` are stage transforms, not peer planners
- `.claude/agents/planning-grill-reviewer.md` is the dedicated adversarial reviewer used during planning
- implementation, code review, and test review happen after planning ends

## Roles

### Master Planner
- owns user interaction during planning
- owns the entire planning lifecycle from discovery through task packet approval
- creates and maintains the planning artifact folder
- determines the current planning phase and internal step
- determines the correct `user_gate`
- invokes the correct planning skill for the current step
- invokes the dedicated grilling reviewer at the required challenge points
- preserves artifact continuity across phases
- prevents execution from starting before task packet approval

### Planning Skills
- transform one planning artifact into the next
- do not own workflow phase
- do not choose `user_gate`
- do not auto-advance
- do not redefine artifact schemas from this protocol

### Planning Grill Reviewer
- challenges the current planning artifact
- pressure-tests assumptions, edge cases, risks, alternatives, and tradeoffs
- does not own the user conversation
- does not produce the final approved artifact
- returns findings and questions to the master planner for synthesis

### Execution Agents
- consume approved task packets
- implement one task or one safe parallel lane at a time
- return work to review and test agents outside the planning workflow

## Artifact Storage

Every new planning engagement must create a new folder at:
- `plans/<plan-id>/`

Recommended `plan-id` format:
- `YYYY-MM-DD-short-slug`

Example:
- `plans/2026-03-27-auth-refresh/`

Each planning phase has one canonical markdown artifact in that folder:
- `plans/<plan-id>/01-high-overview.md`
- `plans/<plan-id>/02-contract.md`
- `plans/<plan-id>/03-task-breakdown.md`

Rules:
- create the folder at the start of a new planning engagement
- update the same files as the plan evolves; do not create duplicate files for minor revisions
- create a new folder only when the planning engagement is materially different
- print the current artifact inline when the workflow is waiting on user approval

## Public Phase Model

Canonical phases:
- `discovery_ready`
- `contract_ready`
- `task_packet_ready`
- `blocked`

These are the only public planning phases.

Internal review loops exist inside `discovery_ready` and `contract_ready`, but do not create new public phases.

## Internal Loop Model

### Phase 1: Discovery
Internal steps:
- `discover`
- `problem_challenge` (mandatory grill review)
- `converge`

Purpose:
- understand the actual problem before proposing a solution
- challenge assumptions, scope, goals, and success criteria early

Primary artifact:
- `01-high-overview.md`

Grill review gate:
- the master planner must invoke `planning-grill-reviewer` during `problem_challenge`
- the reviewer's findings must be embedded in the `Problem Challenge` section of the Discovery Output
- the section must include the attribution line: `Reviewed by: planning-grill-reviewer`
- the master planner may synthesize and edit the findings but must not fabricate this section without an actual reviewer invocation
- the Discovery Output must not be presented for user approval until the grill review has been completed and embedded

### Phase 2: Contract
Internal steps:
- `contract_draft`
- `spec_interview`
- `solution_review` (mandatory grill review)
- `converge`

Purpose:
- define the solution contract
- interview for missing details
- pressure-test the design before task breakdown

Primary artifact:
- `02-contract.md`

Grill review gate:
- the master planner must invoke `planning-grill-reviewer` during `solution_review`
- the reviewer's findings must be embedded in the `Solution Review` section of the Contract Packet
- the section must include the attribution line: `Reviewed by: planning-grill-reviewer`
- the master planner may synthesize and edit the findings but must not fabricate this section without an actual reviewer invocation
- the Contract Packet must not be presented for user approval until the grill review has been completed and embedded

### Phase 3: Task Packet
Internal steps:
- `decompose`
- `size_and_sequence`
- `converge`

Purpose:
- turn an approved contract into execution-ready work units

Primary artifact:
- `03-task-breakdown.md`

## Allowed Transitions

Allowed transitions:
- `discovery_ready -> contract_ready | blocked`
- `contract_ready -> task_packet_ready | discovery_ready | blocked`
- `task_packet_ready -> contract_ready | discovery_ready | blocked`

Rules:
- route backward when later review reveals that goals, assumptions, scope, or constraints were wrong
- do not force `blocked` if the artifact remains usable with explicit assumptions
- use `blocked` only when missing information materially changes scope, ownership, interface shape, external behavior, or architectural direction

## User Gate Model

The master planner must report one `user_gate` value on every turn:
- `none`
- `needs_input`
- `needs_approval`

Interpretation:
- `none`: planning may continue without waiting
- `needs_input`: missing user context materially changes the artifact
- `needs_approval`: the artifact is review-ready, but the next phase must wait

Default gate behavior:
- after `Discovery Output`, use `needs_approval` unless blocked
- after `Contract Packet`, use `needs_approval`
- after `Task Packet`, use `needs_approval` before execution handoff

## Planner Response Contract

Every master planner response must report:
- `Current Phase`
- `Current Internal Step`
- `Artifact Produced`
- `Artifact Path`
- `User Gate`
- `What I Need From You`
- `Next Step`

When `User Gate` is `needs_approval`:
- print the full review-ready artifact inline in Claude
- do not force the user to open another file or app to review it
- make the artifact easy to scan in one place

Precedence rules:
- the master planner owns `Current Phase` and `User Gate`
- artifacts own `Readiness`
- artifacts do not declare workflow transitions

## TDD Policy

Default policy:
- use TDD by default for behavior-changing or code-bearing work
- define contract-level test cases before implementation work is decomposed
- plan linked test work before or alongside production changes in the task packet
- if TDD is not applicable, the task packet must say so explicitly and give a reason

Reasonable `tdd_mode: not_applicable` examples:
- docs-only changes
- manual-only external integration checks
- exploratory spikes that are not intended to ship
- infrastructure work where the contract is validated through non-test evidence only

## Traceability IDs

Use stable IDs across artifacts:
- `G-*` goals
- `C-*` constraints
- `A-*` assumptions
- `Q-*` open questions
- `R-*` risks
- `D-*` decisions
- `TC-*` contract test cases
- `T-*` tasks

Rules:
- preserve IDs across revisions when meaning stays the same
- every major decision should connect back to at least one goal or constraint
- every contract test case should trace to goals, decisions, or risks
- every task should trace to relevant goals, decisions, constraints, and test cases
- keep `Known Context` and `Non-Goals` as plain-language sections without IDs

## Review Standards

### Problem Challenge Standard

During discovery, the master planner must invoke `planning-grill-reviewer` to challenge the problem statement itself. This is not optional. The reviewer's findings must be embedded in the `Problem Challenge` section of the Discovery Output with the attribution `Reviewed by: planning-grill-reviewer` before the artifact is presented for user approval.

The review must ask:
- are we solving the right problem?
- what assumptions may be false?
- what constraints are missing?
- what edge cases change scope or success criteria?
- what should explicitly be out of scope?
- what would make this work a bad trade right now?

### Spec Interview Standard

During contract drafting, the master planner must interview for missing detail before approval.

The interview must probe:
- ambiguous behavior
- state transitions
- user-visible failure handling
- operational concerns
- rollout and rollback expectations
- integration boundaries
- edge cases the requester may not have considered

### Solution Review Standard

Before contract approval, the master planner must invoke `planning-grill-reviewer` to pressure-test the proposed design. This is not optional. The reviewer's findings must be embedded in the `Solution Review` section of the Contract Packet with the attribution `Reviewed by: planning-grill-reviewer` before the artifact is presented for user approval.

The review must explicitly cover:
- strongest objections to the design
- alternatives considered
- tradeoffs accepted
- likely failure modes
- recovery expectations
- assumptions most likely to break
- what fails first under growth or complexity

## Task Sizing Guardrails

Task packets must keep work small enough for one focused execution pass.

Rules:
- one task should own one primary behavior change
- one task should fit one focused agent pass
- default max touched surfaces is 3 unless the task is wiring-only
- when TDD is required, split test work from implementation work unless the change is trivially small
- if a task needs multiple architectural decisions, split it before handoff

## Canonical Artifact Schemas

### Discovery Output

```text
## Discovery Output

### Artifact Metadata
- Phase: discovery_ready
- Readiness: ready | ready_with_assumptions | blocked

### Planning Folder
- Plan ID: ...
- Artifact Path: plans/<plan-id>/01-high-overview.md

### What You Told Me
...

### Interpreted Problem
...

### Goals
- `G-*`: ...

### Constraints
- `C-*`: ...

### Known Context
- ...

### Assumptions
- `A-*`: ...

### Open Questions
- `Q-*`: ...

### Non-Goals
- ...

### Success Criteria
- ...

### Key Risks
- `R-*`: ...

### Problem Challenge
- What May Be Wrong About The Current Ask:
  - ...
- Scope / Success Edge Cases:
  - ...
- Hidden Constraints Or Dependencies:
  - ...
- Decisions Needed Before Designing:
  - `D-*`: ...

### Proposed Direction
...

### Decisions Needed From You
- ...

### What I Will Not Guess
- ...
```

### Contract Packet

```text
## Contract Packet

### Artifact Metadata
- Phase: contract_ready
- Risk Level: low | medium | high
- Readiness: ready | ready_with_assumptions | blocked

### Planning Folder
- Plan ID: ...
- Artifact Path: plans/<plan-id>/02-contract.md

### Carried Forward Context
- Goals: `G-*`
- Constraints: `C-*`
- Assumptions: `A-*`
- Open Questions: `Q-*`
- Risks: `R-*`
- Known Context:
  - ...
- Non-Goals:
  - ...

### Interfaces
- Name: ...
  - What It Does: ...
  - Goal / Purpose: ...
  - Notes: ...

### Call Flows
- Name: ...
  - What Happens: ...
  - Goal / Purpose: ...
  - Key Steps: ...

### Behavior Rules
- Name: ...
  - What It Does: ...
  - Goal / Purpose: ...
  - Important Notes: ...

### Error And Failure Handling
- Scenario: ...
  - Detection: ...
  - Local Handling: ...
  - User / System Impact: ...
  - Recovery / Rollback: ...

### Data Shapes
- ...

### Decisions
- `D-*`: ...
  - Why: ...
  - Alternatives Considered: ...
  - Consequences: ...

### Spec Interview Findings
- Missing Details Resolved:
  - ...
- Remaining Ambiguities:
  - ...

### Solution Review
- Strongest Objections:
  - ...
- Why This Design Still Holds Or Needs Rework:
  - ...
- Assumptions Most Likely To Fail:
  - ...
- What Breaks First At Higher Scale / Complexity:
  - ...
- Tradeoffs Accepted:
  - ...

### Contract Test Cases
- `TC-*`
  - Test Case: ...
  - What It Verifies: ...
  - How It Is Checked: automated | manual | inspection
  - Pass Criteria: ...
  - Fail Signal: ...
  - Covers: `G-*`, `D-*`, `R-*`

### Remaining Assumptions
- `A-*`: ...

### Decisions Needed From You
- ...

### What I Will Not Guess
- ...

### Goals And Coverage Summary
| Goal / Decision / Risk | Covered In Contract | Checked By |
| --- | --- | --- |
| `G-*` / `D-*` / `R-*` | Interface / Flow / Rule | `TC-*` |
```

### Task Packet

```text
## Task Packet

### Artifact Metadata
- Phase: task_packet_ready
- User Gate: needs_approval
- Readiness: ready | blocked

### Planning Folder
- Plan ID: ...
- Artifact Path: plans/<plan-id>/03-task-breakdown.md

### Execution Strategy
- Mode: serial | explicit parallel groups
- Why: ...

### Tasks

#### Task `T-*`
- Title: ...
- What: ...
- Why: ...
- Depends On: ...
- Deliverables: ...
- Edge Cases To Handle:
  - ...
- Failure Paths To Cover:
  - ...
- Done When:
  - ...
- How To Verify:
  - automated: ...
  - manual: ...
- Touched Surfaces: ...
- Traceability:
  - Goals: `G-*`
  - Decisions: `D-*`
  - Constraints: `C-*`
  - Risks: `R-*`
  - Verified By: `TC-*`

### Sequencing Notes
- ...

### User Approval Summary
- ...

### Task Coverage Summary
| Task | Goals / Decisions / Risks | Verified By | Notes |
| --- | --- | --- | --- |
| `T-*` | `G-*` / `D-*` / `R-*` | `TC-*` / manual check | ... |

### Do Not Start Until
- the user approves this task packet
```

## Planner To Executor Handoff

Execution subagents may start only after:
- a `Task Packet` exists
- the master planner has most recently reported `Current Phase: task_packet_ready`
- `User Gate: needs_approval` has been satisfied by user approval

Each execution handoff should include:
- task ID
- plain-language task summary
- linked `G-*`, `C-*`, `A-*`, `D-*`, `R-*`, and `TC-*`
- inputs and outputs
- touched surfaces
- edge cases to handle
- failure paths and recovery expectations relevant to the task
- verification steps

## Review Boundary

Planning ends once the task packet is approved for execution.

After that:
- execution agents implement the approved tasks
- review and test agents validate implementation against the task packet and linked `TC-*` cases
- any drift discovered later should be routed back to the relevant planning artifact for refinement

## Operating Rule

A plan is not ready because it is complete.

A plan is ready only when:
- the problem has been challenged
- the design has been defended
- the work has been decomposed
- the user has approved the artifact
