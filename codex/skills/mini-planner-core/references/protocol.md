# Mini Planning Protocol

## Purpose

Use the smallest amount of planning structure that creates clarity.

This protocol separates plans by the question they answer:

- Feature plan: what are we trying to achieve?
- Architecture plan: what shape should the solution take?
- Implementation plan: how do we deliver it?

It is intentionally lightweight. It is meant to reduce vague planning without creating filler.

## Principles

1. Separate by intent, not by ceremony.
2. Start with one plan type and add another only if the work needs it.
3. Keep the required core small.
4. Delete sections that do not apply.
5. Do not write `N/A`.
6. Do not invent dependencies, metrics, risks, or design details just to complete a template.
7. Prefer short bullets over long prose.
8. If something is unknown, say it is unknown.

## Plan Types

### Feature Plan

Use when the main problem is unclear scope, unclear user value, or unclear success criteria.

Questions it answers:

- What problem are we solving?
- What outcome do we want?
- What is in and out of scope?
- How will we judge success?

### Architecture Plan

Use when the main problem is design shape, system boundaries, tradeoffs, or important decisions.

Questions it answers:

- What does the solution need to support?
- What approach are we taking?
- What decisions matter?
- What are the risks and tradeoffs?

### Implementation Plan

Use when the main problem is execution.

Questions it answers:

- What are we shipping?
- What are the main steps?
- What depends on what?
- How will we validate the result?

## When To Use Which

Not every piece of work needs all three plans.

Common combinations:

- small user-facing change: feature plan + implementation plan
- internal refactor: architecture plan + implementation plan
- discovery work: feature plan only
- design spike: architecture plan only
- large or ambiguous effort: all three

## Linking

Do not use a formal trace matrix for now.

Use lightweight linking only:

- `Related docs`
- `Depends on`
- `Implements`

That is enough to navigate between plans without adding noise.

## Review Rules

Before a plan is considered ready:

1. The right plan type exists for the question being answered.
2. The core sections are present.
3. Unused sections have been removed.
4. The plan does not prescribe details that belong in another plan type.
5. The plan is concrete enough to support the next decision or action.

Helpful review prompts:

- Is the question this document is answering obvious?
- Is anything here filler?
- Is anything here actually a different plan type?
- Are there hidden assumptions that should be named?
- Is the next step clear after reading this?

## Minimal Lifecycle

Use a simple lifecycle:

- `working`
- `approved`

You can add more states later if you feel real pain, but start with these two.

## Anti-Filler Rules For AI

If AI is helping draft plans, it should follow these rules:

1. Include only sections that materially apply.
2. Prefer bullets to paragraphs unless nuance is needed.
3. Do not infer facts without evidence.
4. Do not create fake certainty.
5. If a plan type does not apply, do not generate it.

## Default Bias

When in doubt:

- choose fewer plan types
- choose fewer sections
- keep the document short
- preserve ambiguity when the answer is not known yet
