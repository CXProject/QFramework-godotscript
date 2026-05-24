---
name: qframework-godot-business
description: Implement new business logic, gameplay workflows, purchase/upgrade flows, save/load behavior, model/system/command changes, and UI-to-business integrations in Godot projects using QFramework-style GDScript. Use when Codex needs to add or refactor gameplay rules, Commands, Systems, Models, Queries, Events, or Controllers while preserving a layered Controller, Command, System, Model, and Event architecture.
---

# QFramework Godot Business Logic

Use this skill when implementing or refactoring business logic in a Godot project that uses QFramework-style GDScript architecture.

Core rule: keep gameplay rules out of UI/Controller code. Drive business changes through `GameManager.send_command(...)`, concentrate rules in Systems, store state in Models, and use Events only to notify presentation code after state changes.

For detailed patterns and project-derived examples, read `references/qframework-godot-patterns.md` when the task involves architecture decisions, unclear layer ownership, or refactoring existing logic.

## Workflow

1. Inspect the relevant existing files before editing:
   - `Scripts/controllers` for UI/scene/input entry points.
   - `Scripts/commands` for one-shot workflows.
   - `Scripts/systems` for rules and cross-Model logic.
   - `Scripts/models` for state and save/load data.
   - `Scripts/queries` for cross-Model read-only projections.

2. Classify the requested logic:
   - Controller: input, UI refresh, animation, node manipulation, event listening, command dispatch.
   - Command: one user/game action or transaction, such as buy, upgrade, harvest, save, change setting.
   - System: game rules, validation, calculations, cross-module behavior.
   - Model: state only, plus light save/load serialization.
   - Query: read-only composition across multiple Models for UI or reports.
   - Utility/Autoload: technical services such as file IO, window/platform APIs, time helpers.

3. Implement through the preferred chain:

```text
Controller / UI / Scene
    -> GameManager.send_command(XxxCommand.new(...))
        -> System validates/applies rules
            -> Model state changes
                -> Event notifies UI/animation
```

4. Keep Commands thin:
   - Let Commands orchestrate the flow.
   - Move repeated validation, calculations, and domain rules into Systems.
   - If a Command grows beyond roughly 50 lines or repeats logic from another Command, extract a System method.

5. Keep Controllers presentation-focused:
   - Controllers may compute simple UI availability such as `player_mod.point >= cost`.
   - Controllers must not own rules like whether a refund happens, how much an upgrade costs after modifiers, or whether a gameplay action is valid.
   - Prefer creating a new Command instead of making a Controller modify several Models.

6. Keep Events as notifications:
   - Trigger Events after the Command/System has changed state.
   - Use Events for UI refreshes, animations, toasts, and managers reacting to completed changes.
   - Do not build main business flow as Event -> Event -> Event chains.

7. Preserve the project's save conventions:
   - Models/Systems that need persistence should implement `save_common_data`, `load_common_data`, `save_level_data`, or `load_level_data` as appropriate.
   - Let `saveSystem` organize save data.
   - Prefer `saveDataCommand` from gameplay flows instead of direct file writes.

## Common Implementation Patterns

For a new purchase or upgrade flow:

```text
UI button
    -> BuyOrUpgradeXxxCommand
        -> shopSystem / XxxSystem check method
        -> changePointCommand and domain-specific change command
        -> saveDataCommand
        -> xxx_finished_event or xxx_changed_event
            -> UI refresh / toast
```

For a new gameplay rule:

```text
Config/Model data
    -> XxxSystem rule calculation
        -> Model mutation
            -> Event notification
                -> Controller presentation update
```

For a read-only UI list that combines data:

```text
Controller
    -> GameManager.send_query(XxxQuery.new())
        -> Query reads multiple Models
            -> returns view-friendly data
```

## Review Checklist

Before finishing, verify:

- UI code sends Commands rather than directly applying gameplay changes.
- Business validation lives in a System when it may be reused or has domain meaning.
- Model code stores state and save/load data, not UI or workflow logic.
- Events are named like completed facts, for example `xxx_changed_event` or `xxx_finished_event`.
- New persistent state participates in the save/load convention.
- Existing user changes are preserved; do not rewrite unrelated project architecture.
