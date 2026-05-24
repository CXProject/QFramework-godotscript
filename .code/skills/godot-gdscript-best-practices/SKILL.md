---
name: godot-gdscript-best-practices
description: Review, plan, or implement maintainable Godot 4 GDScript architecture and coding patterns for medium or large projects. Use when Codex needs guidance on scene and node boundaries, controller and service layering, typed GDScript, Resource-driven configuration, signals and process usage, save/load structure, performance tradeoffs, or when turning project-specific habits into reusable Godot GDScript best practices.
---

# Godot GDScript Best Practices

Use this skill to reason about Godot GDScript code without assuming any specific gameplay framework.

Read `references/godot-gdscript-best-practices.md` when the task involves architecture decisions, code review standards, refactoring direction, or turning a project's local patterns into general Godot guidance.

## Workflow

1. Inspect the relevant Godot files before deciding on structure:
   - Scene and Node scripts for input, animation, UI, and lifecycle.
   - Data/config definitions such as `Resource`, model, or config scripts.
   - Save/load, utility, and timing code if the change affects persistence or update flow.

2. Classify the logic before editing:
   - Presentation: input, animation, UI refresh, sound, scene flow, node manipulation.
   - Rules: validation, calculations, AI, growth, combat, economy, progression.
   - Data: current state, configuration, serialization, read-only projections.

3. Prefer these boundaries:
   - Let Node scripts initiate actions and update presentation.
   - Keep reusable gameplay rules in plain GDScript classes, services, or systems.
   - Keep state and serialization in data-focused classes.
   - Keep read-only aggregation separate from mutation logic.

4. Keep performance decisions proportional:
   - Prefer event-driven updates over unnecessary `_process` UI polling.
   - Use typed GDScript by default for shared interfaces and data structures.
   - Reach for pooling, batching, MultiMesh, or C# only after profiling shows a real hotspot.

## Review Checklist

- Presentation code is not quietly accumulating business rules.
- Repeated or reusable rules are centralized instead of copied across multiple entry points.
- Configuration is data-driven where practical instead of hardcoded in node scripts.
- Signals express facts that happened, not hidden chains of core business flow.
- Save/load responsibilities are separated from unrelated gameplay and UI concerns.
- Types are explicit enough that interfaces and collections are easy to reason about.
