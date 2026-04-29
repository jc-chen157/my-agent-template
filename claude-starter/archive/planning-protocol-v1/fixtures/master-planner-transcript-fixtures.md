# Master Planner Transcript Fixtures

Use these fixtures to sanity-check the planning workflow without editing code.

## Fixture 01: Vague Request Stops After Discovery Output

Intent:
- verify that a vague request produces a `Discovery Output`
- verify that the master planner pauses at the required approval gate
- verify that the first planning artifact is written to `01-high-overview.md`

Expected behavior:
- `Current Phase` is `discovery_ready`
- `Current Internal Step` is `converge`
- `Artifact Produced` is `Discovery Output`
- `Artifact Path` points to `plans/<plan-id>/01-high-overview.md`
- `User Gate` is `needs_approval`
- the artifact includes `Assumptions`, `Open Questions`, `Success Criteria`, `Problem Challenge`, `Decisions Needed From You`, and `What I Will Not Guess`
- the planner does not generate a contract packet before approval

## Fixture 02: Missing Material Input Uses Blocked

Intent:
- verify that the planner blocks only when missing context materially changes the design

Expected behavior:
- `Current Phase` is `blocked`
- `User Gate` is `needs_input`
- `What I Need From You` names the exact missing decision
- the planner explains why that missing input materially changes the contract or task packet

## Fixture 03: Discovery Uses Dedicated Problem Challenge

Intent:
- verify that discovery is not just a summary pass
- verify that the dedicated grilling reviewer is used to challenge the problem before contract drafting

Expected behavior:
- the discovery artifact includes a populated `Problem Challenge` section
- the planner surfaces hidden assumptions, scope edge cases, or weak success criteria
- the planner still owns the user-facing artifact and phase reporting
- the grilling reviewer does not replace the master planner

## Fixture 04: Contract Review Stops For Manual Validation

Intent:
- verify that the planner always stops after the contract packet for manual user review

Expected behavior:
- the `Contract Packet` is printed inline in the Claude console
- `Current Phase` is `contract_ready`
- `User Gate` is `needs_approval`
- `Artifact Path` points to `plans/<plan-id>/02-contract.md`
- the planner does not continue to task packet generation until the user approves the contract
- the contract sections read as plain-language summaries, not dense cross-references

## Fixture 05: Contract Includes Spec Interview And Solution Review

Intent:
- verify that contract planning includes both clarification and adversarial challenge

Expected behavior:
- the contract includes `Spec Interview Findings`
- the contract includes `Solution Review`
- the `Solution Review` covers objections, tradeoffs, and likely failure modes
- the grilling reviewer contributes findings, but the master planner owns the final artifact

## Fixture 06: Task Packet Enforces Sizing

Intent:
- verify that the task packet stays small enough for focused execution

Expected behavior:
- oversized work is split before execution handoff
- one task does not mix multiple architectural decisions
- test work is split from implementation work when TDD is required
- each task reads as a short implementation checklist rather than a traceability record
- each task carries forward the relevant edge cases and failure paths from the contract
- `Artifact Path` points to `plans/<plan-id>/03-task-breakdown.md`

## Fixture 07: Planner Surfaces Non-Guess Boundaries

Intent:
- verify that the planner forces clarity instead of guessing

Expected behavior:
- every artifact includes `Assumptions`
- discovery and contract artifacts include `Decisions Needed From You`
- discovery and contract artifacts include `What I Will Not Guess`
- low-impact preferences are carried as assumptions instead of blocking
- the contract ends with a table showing goals, decisions, risks, and how they are covered
- the task packet ends with a compact task coverage table instead of inline ID-heavy bullets

## Regression Checklist

The master planner must never:
- delegate execution before the task packet is approved
- drop `Constraints`, `Known Context`, `Assumptions`, or `Non-Goals` across artifacts
- let a planning skill decide the workflow phase or `user_gate`
- let the grilling reviewer own the user conversation or final artifact
- skip `TC-*` definition for behavior-changing contract work
- decompose code-bearing work without linked test cases when TDD is required
- perform post-implementation validation inside the planning workflow
