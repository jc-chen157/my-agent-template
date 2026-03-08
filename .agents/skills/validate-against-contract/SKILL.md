# Validate Against Contract Skill

Evaluate completed work against the agreed contract packet and task packet before merge or handoff.

## When to Use
- Implementation work is complete or partially complete
- A diff, PR, summary, or artifact bundle needs to be checked against the planned contracts
- User asks "did this match the plan?" / "what is missing?" / "is this ready?"
- Before merging or handing work to another engineer or agent

---

## Core Philosophy

The evaluator should not grade work by vibes. It should grade work against explicit promises: the contract packet and the task packet. Validation is a separate stage so contract drift, missed behaviors, and hidden regressions are detected before the work moves on.

### Principles

| Principle | Meaning |
|-----------|---------|
| **Evaluate against promises** | Compare delivered work to contracts and task acceptance checks |
| **Separate coverage from quality** | Distinguish missing functionality from risky or regressive implementation |
| **Use explicit statuses** | Return `pass`, `partial`, or `fail` with reasons |
| **Retry instructions must be actionable** | Point to contract IDs and task IDs, not generic advice |
| **Drift is a finding** | If the implementation changes the contract silently, call it out |

---

## Workflow

## Step 1: Collect Validation Inputs

Work from the strongest evidence available:

- Contract packet
- Task packet
- Diff, PR, implementation summary, or produced artifacts
- Tests or verification notes if available

If evidence is incomplete, say so. Do not pretend a full validation happened.

## Step 2: Check Contract Coverage

For each relevant contract ID, determine whether the delivered work:

- Fully satisfies it
- Partially satisfies it
- Misses it entirely
- Changes it without updating the contract packet

Review entities, interfaces, behaviors, state transitions, and flow contracts separately when needed.

## Step 3: Check Task Coverage

For each task in the task packet, determine whether:

- Outputs exist
- Acceptance checks appear satisfied
- Dependencies were respected
- Merge points were handled correctly

## Step 4: Identify Regressions and Drift

Flag:

- Missing named error behaviors
- Broken or absent acceptance scenarios
- Changed request or response shapes
- Dependency mismatches
- Shared-surface collisions or incomplete integration
- Regressions introduced outside the targeted work

## Step 5: Return Status and Next Action

Use these meanings consistently:

- `pass`: contracts and tasks are satisfied well enough to hand off or merge
- `partial`: core direction is correct, but gaps remain
- `fail`: key contracts, tasks, or regressions block progress

Always include an exact next action. If retry is needed, say which task or contract slice should be retried and what must change.

---

## Good vs Bad Validation

```text
Bad:
- "Looks mostly good. A few things may need cleanup."

Why bad:
- No status
- No contract coverage
- No task linkage
- No retry target

Better:
- Status: partial
- Missing: `method.user_service.create` does not return the contracted error on duplicate email
- Drift: request shape added `displayName` but the contract packet was not updated
- Next action: retry Task T03 against `method.user_service.create` and update tests for the duplicate-email path
```

---

## Public Output Contract

Return a markdown validation report with a compact structured block.

````markdown
# Validation Report: [Feature or Module Name]

## Status
- `pass` | `partial` | `fail`
- Why: ...

## Contract Coverage
- Covered: ...
- Partial: ...
- Missing: ...
- Drift: ...

## Task Coverage
- Complete: ...
- Incomplete: ...
- Dependency issues: ...

## Gaps
- ...

## Regressions
- ...

## Next Action
- Type: `merge` | `retry_task` | `update_contract` | `gather_more_evidence`
- Target: task ID, contract ID, or both
- Instructions:
  - ...

```yaml
status: partial
contract_coverage:
  covered:
    - entity.user
  partial:
    - method.user_service.create
  missing: []
  drift: []
task_coverage:
  complete:
    - T01
  incomplete:
    - T03
  dependency_issues: []
gaps:
  - contract_id: method.user_service.create
    issue: Duplicate email behavior not implemented
regressions: []
next_action:
  type: retry_task
  target: T03
```
````

---

## Validation Checklist

- [ ] The report states what evidence was reviewed
- [ ] Every relevant contract ID is classified as covered, partial, missing, or drifted
- [ ] Every relevant task is classified as complete or incomplete
- [ ] Regressions are called out separately from missing scope
- [ ] The final status is consistent with the findings
- [ ] The next action is explicit enough for another agent to execute

---

## Related Skills

- `initial-planning` - Produces the planning brief that starts the workflow
- `define-contract` - Produces the contract packet being validated
- `break-down-plan` - Produces the task packet being validated
