---
name: react-frontend
description: Use this skill for React and TypeScript frontend work and review. It provides stack-specific guidance for modern React state management, effects, accessibility, and type modeling.
---

# React Frontend

Use these defaults:

- TypeScript
- React

Guidance:

- Keep components and Hooks pure.
- State should live in the narrowest owner.
- Derive values during render instead of synchronizing redundant state.
- Use effects only for synchronization with external systems.
- Model UI state with precise TypeScript types.
- Keep accessibility, loading states, and error states explicit.

Review heuristics:

- Unnecessary `useEffect`
- Redundant or badly placed state
- Weak TypeScript types and `any`
- Accessibility regressions
- Overgrown components or hooks that hide control flow
- Premature memoization
