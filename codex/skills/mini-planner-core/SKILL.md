---
name: mini-planner-core
description: "Use this project-local skill when the user asks for lightweight planning, uses a planning prefix, wants plan documents before implementation, or needs scope, architecture, or implementation steps clarified without the formal contract-packet workflow. It follows planning-protocol-v2: choose only the needed feature, architecture, and implementation plans; keep them short; delete inapplicable sections; and do not implement code while planning."
---

# Mini Planner Core

Use this skill when the task is:

- planning or scoping before implementation
- turning a rough request into one or more lightweight plan documents
- deciding whether the work needs a feature plan, architecture plan, implementation plan, or a small combination
- revising an existing lightweight plan without introducing heavier planning ceremony

Read first:

- `references/protocol.md`

Use templates as needed:

- `references/feature-plan.md`
- `references/architecture-plan.md`
- `references/implementation-plan.md`

Workflow:

- choose the smallest set of plan types that answers the actual question
- state the chosen plan types and the reason in one line
- create or update only the plan files that apply
- delete template sections that do not apply; do not write `N/A`
- keep plans short, concrete, and honest about unknowns
- stop for user input only when missing information would change the plan shape
- keep each plan in `Status: working` until the user explicitly approves it
- do not implement code while operating as the planner

Default plan selection:

- small user-facing change: feature plan + implementation plan
- internal refactor: architecture plan + implementation plan
- discovery work: feature plan only
- design spike: architecture plan only
- large or ambiguous effort: all three

Storage:

- default new-plan layout is `plans/<short-slug>/feature-plan.md`, `plans/<short-slug>/architecture-plan.md`, and `plans/<short-slug>/implementation-plan.md`
- create only the files that apply
- if the repository already has a planning location or naming convention, follow it
- update the same plan file as it evolves; do not fork copies for minor revisions

Response format when producing or updating plans:

- `Plan Types Chosen`: plan names plus one-line reason
- `Files Touched`: paths
- `Status`: `working` or `approved` per plan
- `What I Need From You`: concrete asks, or `nothing`
- `Next Step`: the next decision or action

Rules:

- do not generate every plan type by default
- do not invent goals, risks, dependencies, decisions, metrics, or design details to fill a template
- do not add lifecycle states beyond `working` and `approved`
- do not add a formal trace matrix, requirement IDs, or test-case ID system
- use only lightweight links: `Related docs`, `Depends on`, and `Implements`
- if reality drifts from an approved plan, revise the relevant plan before continuing
- when a plan is review-ready, print it inline so the user can review it without opening a file
