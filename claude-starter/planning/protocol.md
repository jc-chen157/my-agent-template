# Planning Protocol

This document is the canonical planning workflow contract for this repository.

It defines:
- planning phases
- user gates
- canonical planning artifact schemas
- traceability IDs
- TDD expectations
- planner-to-executor handoff rules

## Purpose

The planning system should be:
- human-readable first
- artifact-driven rather than conversationally implied
- strict enough that downstream execution agents do not guess
- small enough that the planner does not burn context on workflow ceremony

## Source Of Truth

Use these rules when planning:
- `.claude/planning/protocol.md` is the canonical planning protocol
- `.claude/agents/master-planner.md` is the only planning orchestrator
- `.claude/skills/planning-*.md` are stage transforms, not peer planners
- review and test agents validate implementation after planning ends

## Roles

### Master Planner
- owns user interaction during planning
- determines the current planning phase from available artifacts and user input
- chooses the current `user_gate`
- invokes the right planning skill for the current phase
- preserves artifact continuity across planning stages
- prevents execution from starting before task packet approval

### Planning Skills
- transform one planning artifact into the next
- do not own planning phase
- do not choose `user_gate`
- do not auto-advance the workflow
- do not redefine artifact schemas from this protocol

### Execution Subagents
- consume approved task packets
- implement one task or one safe parallel lane at a time
- return work to review and test agents outside the planning workflow

## Planning Phases

Canonical phases:
- `draft_request`
- `brief_ready`
- `contract_ready`
- `task_packet_ready`
- `blocked`

Allowed transitions:
- `draft_request -> brief_ready | blocked`
- `brief_ready -> contract_ready | blocked`
- `contract_ready -> task_packet_ready | blocked`
- `task_packet_ready -> contract_ready | brief_ready | blocked`

Phase rules:
- `blocked` is reserved for missing information that materially changes scope, ownership, interface shape, external behavior, or architectural direction
- if the artifact is usable with explicit assumptions, keep the phase steady and surface the assumptions instead of forcing `blocked`
- if implementation review finds drift later, route the work back to the correct planning artifact outside this state model

## User Gate Model

The master planner must report one `user_gate` value on every turn:
- `none`
- `needs_input`
- `needs_approval`

Interpretation:
- `none`: planning may continue without waiting on the user
- `needs_input`: missing user context materially changes the contract or task packet
- `needs_approval`: the artifact is ready enough, but the next phase or execution must wait for the user

Default gate behavior:
- after the `Initial Planning Brief`, use `needs_approval` unless the phase is `blocked`
- after the `Contract Packet`, use `needs_approval` so the user can manually validate the design before task breakdown
- after the `Task Packet`, use `needs_approval` before any execution handoff

## Planner Response Contract

Every master planner response must report:
- `Current Phase`
- `Artifact Produced`
- `User Gate`
- `What I Need From You`
- `Next Step`

When `User Gate` is `needs_approval`:
- print the full review-ready artifact inline in the Claude console
- do not force the user to open another app or file just to read the artifact
- make the artifact easy to scan in one place before asking for approval

Precedence rules:
- the master planner owns `Current Phase` and `User Gate`
- artifacts own `Readiness`
- artifacts do not declare workflow transitions or recommended next states

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
- `TC-*` contract test cases
- `T-*` tasks

Traceability rules:
- every contract test case must cite at least one `G-*`
- every task must cite the relevant `G-*`, `C-*`, `A-*`, and `TC-*` items
- preserve IDs across revisions when the meaning stays the same
- keep `Known Context` and `Non-Goals` as plain-language sections without IDs
- use plain-language names for interfaces, call flows, and behaviors instead of low-level ID taxonomies
- keep traceability references compact and out of the main prose when a human-readable summary is clearer

## Task Sizing Guardrails

Task packets must keep work small enough for one focused execution pass.

Rules:
- one task should own one primary behavior change
- one task should fit one focused agent pass
- default max touched surfaces is 3 unless the task is wiring-only
- when TDD is required, split test work from implementation work unless the change is trivially small
- if a task needs multiple architectural decisions, split it before handoff

## Canonical Artifact Schemas

The following output contracts are normative. Planning skills should produce these artifacts and not redefine their headings.

### Initial Planning Brief

```text
## Initial Planning Brief

### Artifact Metadata
- Phase: brief_ready
- Readiness: ready | ready_with_assumptions | blocked

### What You Told Me
...

### Interpreted Goal
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

### Carried Forward Context
- Goals: `G-*`
- Constraints: `C-*`
- Assumptions: `A-*`
- Open Questions: `Q-*`
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

### Error Cases
- ...

### Data Shapes
- ...

### Contract Test Cases
- `TC-*`
  - Test Case: ...
  - What It Verifies: ...
  - How It Is Checked: automated | manual | inspection
  - Pass Criteria: ...
  - Fail Signal: ...
  - Notes: ...

### Remaining Assumptions
- `A-*`: ...

### Decisions Needed From You
- ...

### What I Will Not Guess
- ...

### Goals And Coverage Summary
| Goal / Design Item | Covered In Contract | Checked By |
| --- | --- | --- |
| `G-*` ... | Interface / Flow / Behavior names | `TC-*` |
```

### Task Packet

```text
## Task Packet

### Artifact Metadata
- Phase: task_packet_ready
- User Gate: needs_approval
- Readiness: ready | blocked

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
- Done When:
  - ...
- How To Verify:
  - automated: ...
  - manual: ...
- Touched Surfaces: ...

### User Approval Summary
- ...

### Task Coverage Summary
| Task | Goals / Design Items | Verified By | Notes |
| --- | --- | --- | --- |
| `T-*` | `G-*` ... | `TC-*` / manual check | ... |

### Do Not Start Until
- the user approves this task packet
```

## Planner To Executor Handoff

Execution subagents may start only after:
- a `Task Packet` exists
- the master planner has most recently reported `Current Phase: task_packet_ready` with `User Gate: needs_approval`
- the user has approved execution

Each execution handoff should include:
- task ID
- task summary in plain language
- linked `G-*`, `C-*`, `A-*`, and `TC-*` in compact form
- inputs and outputs
- touched surfaces
- verification steps

## Review Boundary

Planning ends once the task packet is approved for execution.

After that:
- execution agents implement the approved tasks
- review and test agents validate implementation against the task packet and linked `TC-*` cases
- any drift discovered later should be routed back to the relevant planning artifact for refinement

## Legacy Policy

The active planning source of truth is:
- `.claude/planning/protocol.md`
- `.claude/agents/master-planner.md`
- `.claude/skills/planning-*.md`

Legacy prompts and validation-only planning flows should remain outside the active planner path.
