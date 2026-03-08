# React Frontend Skill

Use this skill with `frontend-engineer` or `code-review-engineer` when the project is a React + TypeScript frontend.

## Stack Defaults

- TypeScript
- React

## Implementation Guidance

- Keep components and Hooks pure.
- State should live in the narrowest owner.
- Derive values during render instead of synchronizing redundant state.
- Use effects only for synchronization with external systems.
- Model UI state with precise TypeScript types and discriminated unions where helpful.
- Keep accessibility, loading states, and error states explicit.

## Review Heuristics

- Unnecessary `useEffect`
- Redundant or badly placed state
- Weak TypeScript types and `any`
- Accessibility regressions
- Overgrown components or hooks that hide control flow
- Premature memoization
