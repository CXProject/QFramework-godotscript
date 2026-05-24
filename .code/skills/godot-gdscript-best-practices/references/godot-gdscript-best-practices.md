# Godot GDScript Best Practices

This reference summarizes durable Godot 4 + GDScript practices for medium and large projects. It is framework-agnostic. If a project uses MVC, ECS-lite, QFramework-like layering, or ad hoc services, map these ideas onto the existing structure instead of forcing a rewrite.

## Core Model

Think in three layers first:

- Presentation: UI, animation, input, sound, scene flow, collision feedback, node lifecycle.
- Rules: calculations, validation, progression, AI, combat, spawning, economy, growth.
- Data: current state, configuration, save data, read-only view models.

Useful questions:

- Would this logic still make sense with a different UI? If yes, it likely does not belong in the UI script.
- Is this code deciding how the game world changes? If yes, keep it in a rules-oriented class.
- Is this code mostly storing fields, converting save data, or exposing config? If yes, keep it data-focused.

## Nodes And Scene Boundaries

Avoid "everything is a Node." Nodes are lightweight, but deep scene trees and excessive signals become expensive to debug and maintain.

Prefer:

- Nodes for lifecycle, visuals, animation, input, collision, and scene composition.
- Plain GDScript classes or lightweight services for reusable game rules.
- Data classes or `Resource` files for configuration and state.

Composition is usually safer than deep inheritance trees. Split behavior into capabilities instead of building long parent-child chains.

## Presentation Boundaries

Presentation code may:

- Read state to decide what to show.
- Dispatch an action when the player clicks or drags.
- React to a completed state change by refreshing UI or playing feedback.

Presentation code should not:

- Quietly modify several data objects to complete a transaction.
- Own pricing, refund, queue, upgrade, or validation rules.
- Mix save/load logic into routine UI flow.

If a button handler starts deciding costs, caps, eligibility, or multiple side effects, move that logic into a reusable rules layer.

## Rules Layer

The rules layer should answer: "How does this game mechanic work?"

Good fits:

- Damage calculation
- Growth and spawn logic
- Reward and loot logic
- Upgrade or shop validation
- AI decisions
- Time progression rules

Guidelines:

- Centralize repeated checks instead of duplicating them across multiple actions.
- Let rules depend on data, but avoid direct dependence on specific UI nodes.
- Split oversized functions into smaller helpers before introducing new modules.

## Data Layer

Keep data classes focused:

- Store state.
- Expose configuration.
- Provide lightweight save/load transforms.

Avoid placing full workflows in data classes. A data object should not also be responsible for UI refreshes, hidden business transactions, or file IO.

Use `Resource` or config structures for data that designers or future maintainers will tune frequently:

- Names, descriptions, icons, scene paths
- Costs, weights, tags, rarity
- Enemy stats, loot tables, skill properties
- Growth parameters and tuning values

Simple rule:

- "What exists" belongs in config.
- "How it behaves" belongs in rules.
- "How it looks" belongs in presentation.

## Typed GDScript

Default to typed GDScript, especially for:

- Public properties and function arguments
- Return values
- Config/data structures
- Arrays and dictionaries that cross module boundaries

Benefits:

- Better editor support
- Easier refactors
- Fewer runtime surprises
- Clearer team communication

## Signals And `_process`

Do not treat `_process` or global signals as the default answer to every update problem.

Prefer:

- Event-driven UI refresh when state changes
- Timers or aggregated ticks for low-frequency checks
- Direct method calls for hot paths that do not need broadcast semantics

Use `_process` when it is genuinely tied to frame updates, motion, animation, or a controlled timing loop.

Warning signs:

- UI labels updated every frame from unchanged values
- Frequent string building in `_process`
- Many nodes polling the same state independently
- Broadcast signals used for high-frequency mechanics

## Read-Only Aggregation

When UI needs combined data from several sources, create a read-only aggregation layer instead of teaching the UI how to stitch everything together.

Good fit:

- Collection screens
- Inventory lists
- Shop displays
- Combined HUD summaries

Rule of thumb:

- One simple field: read directly.
- Several sources combined for display: extract a read-only projection.
- Any mutation or business validation: move back to the rules layer.

## Events

Events should communicate facts that already happened:

- points changed
- save finished
- item bought
- enemy died
- crop matured

Avoid using events as the main hidden chain for business flow. Core flow should stay explicit:

```text
presentation starts action
rules apply changes
data updates
events notify presentation
```

## Save And IO

Separate "what data should be saved" from "how bytes are written."

Prefer:

- Save system or coordinator gathers relevant state.
- IO utility handles file paths, compression, encryption, and file access details.

This keeps persistence readable and prevents gameplay systems from accumulating low-level file concerns.

## Performance Escalation

Do not over-engineer early. Profile first.

Consider more advanced optimization only when profiling confirms a hotspot:

- object pools for heavy instantiate/free churn
- batched updates for large groups
- MultiMesh for many similar visuals
- server APIs for very large object counts
- C# for heavy pure computation or large data processing

If mixing GDScript and C#, a durable boundary is:

- GDScript for nodes, scenes, UI, input, and integration
- C# for pure computation, simulation, and batch processing

Keep the dependency direction simple. Avoid deep back-and-forth calls between GDScript and C#.

## Review Heuristics

When reviewing a Godot GDScript change, check these first:

- Did a UI or scene script start owning business rules?
- Is duplicated validation appearing across multiple actions?
- Is configuration hardcoded where data should live?
- Is `_process` doing work that should be event-driven?
- Are signals carrying too much hidden core flow?
- Is a single script growing into a god object?
- Are types clear enough to make interfaces safe to change?
