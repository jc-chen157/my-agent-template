---
name: rust-desktop
description: Use this skill for Rust desktop application work and Rust desktop code review. It provides stack-specific guidance for egui, iced, and Tauri.
---

# Rust Desktop

Use these defaults:

- egui / eframe
- iced
- Tauri

Guidance:

- Treat the UI as a projection of state.
- Keep long-running work off the UI thread.
- Choose egui for fast iteration and internal tools.
- Choose iced for explicit message/update architecture.
- Choose Tauri when a web UI plus Rust-native shell is the right tradeoff.
- Keep IPC boundaries explicit and validated.

Review heuristics:

- UI freezing due to work on the main thread
- Leaky state transitions
- Overgrown commands or IPC surfaces
- Weak persistence or reconnect behavior
- Background tasks mutating UI state unsafely
