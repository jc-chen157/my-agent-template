# Traceability Sample

This fixture should match the schemas in `planning/protocol.md`; update both together.

Use this worked example to manually inspect end-to-end traceability across the planning artifacts.

## Discovery Output

### Goals
- `G-01`: Users can submit a planning request and receive an approved task packet before any implementation starts.

### Constraints
- `C-01`: The workflow must remain Claude-only for now.

### Known Context
- The repository uses a single master planner plus planning stage skills and a dedicated grilling reviewer.

### Assumptions
- `A-01`: Planning artifacts are stored under `plans/<plan-id>/`.

### Open Questions
- `Q-01`: Should task packets always split test and implementation work when TDD is required, or only when the change is non-trivial?

### Non-Goals
- Codex parity is not part of this pass.

### Success Criteria
- The user can review one artifact per phase without leaving Claude.

### Key Risks
- `R-01`: The planner may produce a clean summary without actually challenging the problem or design.

### Problem Challenge
- What May Be Wrong About The Current Ask:
  - The process could still be approval-driven rather than challenge-driven.
- Scope / Success Edge Cases:
  - The planner might skip the discovery challenge and jump straight to contract drafting.
- Hidden Constraints Or Dependencies:
  - The artifact storage convention must be consistent across planner docs and examples.
- Decisions Needed Before Designing:
  - `D-01`: Use one planner-owned folder per planning engagement.

## Contract Packet

### Interfaces
- Name: Planning Orchestrator
  - What It Does: decides which planning artifact to produce next without guessing missing context
  - Goal / Purpose: keep planning readable while still enforcing approval gates
  - Notes: keeps phase and user gate separate

### Call Flows
- Name: request -> discovery -> contract -> task packet
  - What Happens: the planner turns a rough request into an approved task packet in three readable stages
  - Goal / Purpose: keep the user in the loop before implementation starts
  - Key Steps: capture user context, challenge the problem, define contract, challenge the solution, split work, stop for approval before execution

### Behavior Rules
- Name: Gate execution on task packet approval
  - What It Does: prevents implementation from starting until the task packet is approved
  - Goal / Purpose: ensure the user confirms scope before execution begins
  - Important Notes: approval is a user checkpoint, not an artifact readiness flag

### Error And Failure Handling
- Scenario: Discovery challenge is skipped
  - Detection: discovery artifact lacks `Problem Challenge`
  - Local Handling: return to discovery and complete the challenge pass
  - User / System Impact: the plan may move forward with weak assumptions
  - Recovery / Rollback: revise `01-high-overview.md` before contract drafting

### Decisions
- `D-01`: Use one planner-owned folder per planning engagement
  - Why: keeps the lifecycle artifacts grouped and easy to review
  - Alternatives Considered: a single rolling plan file; ad hoc notes only in chat
  - Consequences: more file discipline, but much better traceability

### Spec Interview Findings
- Missing Details Resolved:
  - The planner must stay the owner across all planning phases.
- Remaining Ambiguities:
  - Whether the grilling reviewer should run on every revision or only approval-bound revisions.

### Solution Review
- Strongest Objections:
  - The process may become heavier than needed for small tasks.
- Why This Design Still Holds Or Needs Rework:
  - The protocol keeps only three public phases and pushes the heavier challenge work into internal loops.
- Assumptions Most Likely To Fail:
  - Teams will remember to create and update the planning folder consistently.
- What Breaks First At Higher Scale / Complexity:
  - Artifact sprawl if plan IDs and folder reuse rules are not followed.
- Tradeoffs Accepted:
  - A slower planning pass in exchange for better decision quality and reviewability.

### Contract Test Cases
- `TC-01`
  - Test Case: Planner stops at the required approval checkpoints
  - What It Verifies: the planner pauses after discovery, after contract, and again before execution instead of self-advancing
  - How It Is Checked: automated
  - Pass Criteria: the transcript fixture reports `User Gate: needs_approval` at the required checkpoints
  - Fail Signal: the planner produces a later artifact or execution handoff without the required user approval
  - Covers: `G-01`, `D-01`, `R-01`

### Goals And Coverage Summary
| Goal / Decision / Risk | Covered In Contract | Checked By |
| --- | --- | --- |
| `G-01` / `D-01` / `R-01` | Planning Orchestrator, request -> discovery -> contract -> task packet, Gate execution on task packet approval | `TC-01` |

## Task Packet

### Artifact Metadata
- Phase: task_packet_ready
- User Gate: needs_approval
- Readiness: ready

### Planning Folder
- Plan ID: `2026-03-27-planning-flow`
- Artifact Path: `plans/2026-03-27-planning-flow/03-task-breakdown.md`

### Execution Strategy
- Mode: serial
- Why: the planner workflow is small enough that each change builds on the prior one

### Tasks

#### Task `T-01`
- Title: Add planning folder lifecycle rules
- What: document the planning folder convention and canonical artifact paths
- Why: artifact persistence is part of the planning contract now
- Depends On: none
- Deliverables: updated planner protocol and master planner guidance
- Edge Cases To Handle:
  - Existing plans should be updated in place rather than creating duplicate folders for small revisions.
  - New planning engagements should create a new folder only when the work is materially different.
- Failure Paths To Cover:
  - Missing or inconsistent artifact paths across docs and fixtures.
  - Planner creates a folder but does not keep all three canonical artifact files aligned.
- Done When:
  - the protocol defines `plans/<plan-id>/`
  - the planner guidance names all three canonical artifact files
- How To Verify:
  - automated: transcript and traceability fixtures align with the artifact paths
  - manual: inspect the docs and confirm the same folder rules appear everywhere
- Touched Surfaces: planning protocol, master planner, fixtures
- Traceability:
  - Goals: `G-01`
  - Decisions: `D-01`
  - Constraints: `C-01`
  - Risks: `R-01`
  - Verified By: `TC-01`

### Task Coverage Summary
| Task | Goals / Decisions / Risks | Verified By | Notes |
| --- | --- | --- | --- |
| `T-01` | `G-01` / `D-01` / `R-01` | `TC-01` automated fixture | verifies persistent planning artifacts and approval checkpoints |

## Manual Review Goal

Confirm that one goal can be traced cleanly through:
- `G-*`
- `D-*`
- `R-*`
- `TC-*`
- `T-*`
- task acceptance checks
