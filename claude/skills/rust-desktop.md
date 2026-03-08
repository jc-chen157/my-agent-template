# Rust Desktop Skill

Use this skill with `frontend-engineer` or `code-review-engineer` when the project is a Rust desktop application.

## Stack Defaults

- egui / eframe
- iced
- Tauri

## Implementation Guidance

- Treat the UI as a projection of state.
- Keep long-running work off the UI thread.
- Choose egui for fast iteration and internal tools.
- Choose iced for explicit message/update architecture.
- Choose Tauri when a web UI plus Rust-native shell is the right tradeoff.
- Keep IPC boundaries explicit and validated.

## Review Heuristics

- UI freezing due to work on the main thread
- Leaky state transitions
- Overgrown commands or IPC surfaces
- Weak persistence or reconnect behavior
- Background tasks mutating UI state unsafely
