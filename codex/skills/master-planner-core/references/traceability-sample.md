# Traceability Sample

This fixture should match the schemas in `references/planning-protocol.md`; update both together.

Use this example to manually inspect end-to-end traceability.

## Initial Planning Brief

### Goals
- `G-01`: Users receive an approved task packet before implementation starts.

### Constraints
- `C-01`: The planning loop must remain artifact-driven.

### Known Context
- The workflow uses one master planner plus execution skills.

### Assumptions
- `A-01`: Low-risk contract work can continue without a separate approval stop.

### Open Questions
- `Q-01`: Should task packets always split test and implementation work when TDD is required, or only when the change is non-trivial?

### Non-Goals
- Execution is not part of the planning phase.

## Contract Packet

### Interfaces
- Name: Planning Orchestrator
  - What It Does: decides which planning artifact to produce next without guessing missing context
  - Goal / Purpose: keep planning readable while still enforcing approval gates
  - Notes: keeps phase and user gate separate

### Call Flows
- Name: request -> brief -> contract -> task packet
  - What Happens: the planner turns a rough request into an approved task packet in three readable stages
  - Goal / Purpose: keep the user in the loop before implementation starts
  - Key Steps: capture user context, define contract, split work, stop for approval before execution

### Behavior Rules
- Name: Gate execution on task packet approval
  - What It Does: prevents implementation from starting until the task packet is approved
  - Goal / Purpose: ensure the user confirms scope before execution begins
  - Important Notes: approval is a user checkpoint, not an artifact readiness flag

### Contract Test Cases
- `TC-01`
  - Test Case: Planner stops at the required approval checkpoints
  - What It Verifies: the planner pauses after the brief and again before execution instead of self-advancing
  - How It Is Checked: automated
  - Pass Criteria: the transcript fixture reports `User Gate: needs_approval` at the required checkpoints
  - Fail Signal: the planner produces a contract or execution handoff without the required user approval
  - Notes: use the transcript fixtures as the expected evidence source

### Goals And Coverage Summary
| Goal / Design Item | Covered In Contract | Checked By |
| --- | --- | --- |
| `G-01` approved task packet before implementation | Planning Orchestrator, request -> brief -> contract -> task packet, Gate execution on task packet approval | `TC-01` |

## Task Packet

### Artifact Metadata
- Phase: task_packet_ready
- User Gate: needs_approval
- Readiness: ready

### Execution Strategy
- Mode: serial
- Why: the planner workflow is small enough that each change builds on the prior one

### Tasks

#### Task `T-01`
- Title: Add planner checkpoint coverage fixture
- What: add a fixture that captures the planner response wrapper at the required approval checkpoints
- Why: checkpoint behavior is contract-critical and should be proven before planner changes are accepted
- Depends On: none
- Deliverables: updated transcript fixture covering brief approval and pre-execution approval
- Done When:
  - the fixture proves the planner reports the required approval gate after the brief
  - the fixture proves execution does not start before task packet approval
- How To Verify:
  - automated: the planner coverage fixture matches the expected approval checkpoints
  - manual: inspect the fixture and confirm it includes `Current Phase`, `Artifact Produced`, `User Gate`, `What I Need From You`, and `Next Step`
- Touched Surfaces: planner prompt, planning protocol, transcript fixtures

### Task Coverage Summary
| Task | Goals / Design Items | Verified By | Notes |
| --- | --- | --- | --- |
| `T-01` | `G-01` approved task packet before implementation | `TC-01` automated fixture | verifies both required approval checkpoints |
