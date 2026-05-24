# QFramework Godot Business Patterns

Use these patterns when layer ownership is unclear or when refactoring existing Godot + QFramework-style GDScript code.

## Layer Ownership

Controller/UI/Scene:

- Own input, node manipulation, animation, audio trigger coordination, UI refresh, Event listening, and Command dispatch.
- Do not own gameplay rules, costs, refunds, unlock conditions, growth rules, save orchestration, or multi-Model mutation.

Command:

- Own one action or transaction: buy, upgrade, collect, harvest, save, load, change setting.
- Orchestrate Systems and smaller Commands.
- Stay thin. Extract repeated checks or calculations into Systems.

System:

- Own game rules, validation, calculations, and cross-Model workflows.
- Can be stateful or stateless.
- Is the right home for rules that would still matter if UI changed.

Model:

- Own state and lightweight save/load conversion.
- Avoid node operations, animation, UI refresh, and business workflows.

Query:

- Own read-only composition across multiple Models.
- Use direct Model reads for simple single-Model access.

Utility/Autoload:

- Own technical services: file IO, window/platform APIs, time helpers, localization, scene loading, audio adapters.

Event:

- Own notification after state changes.
- Use for UI refresh, animation, toasts, and manager reactions.
- Avoid Event-driven business chains.

## Positive Patterns

UI button sends a Command:

```gdscript
func _on_level_up_btn_pressed(can_buy: bool):
	if can_buy == false: return
	GameManager.send_command(UpgradeDeviceCommand.new())
```

Command orchestrates purchase flow:

```gdscript
func execute():
	var shop_sys = architecture.get_system(shopSystem.NAME)
	var event_sys = architecture.get_system(eventSystem.NAME)
	var result = shop_sys.check_buy(config)
	if result.success:
		architecture.send_command(ChangePointCommand.new(-result.cost))
		architecture.send_command(UnlockItemCommand.new(config))
		architecture.send_command(SaveDataCommand.new())
	event_sys.buy_finished_event.trigger(result)
```

System owns gameplay calculation:

```gdscript
func calculate_final_growth_time(base_time: float) -> float:
	var result = base_time
	result *= current_potion.grow_multiplier
	result *= 1.0 - current_device.grow_bonus
	return max(result, current_device.min_growth_time)
```

Model stores state and serialization:

```gdscript
class_name PlayerModel extends AbstractModel

const NAME := "PlayerModel"

var point: int = 0

func save_common_data() -> Dictionary:
	return {"point": point}

func load_common_data(data: Dictionary) -> void:
	point = data.get("point", 0)
```

Query combines Models for UI:

```gdscript
func do():
	var result := []
	var collection = architecture.get_model(CollectionModel.NAME)
	var configs = architecture.get_model(ItemConfigModel.NAME)
	for id in collection.collected_ids:
		if configs.items.has(id):
			result.append({"config": configs.items[id], "count": collection.counts[id]})
	return result
```

## Anti-Patterns To Avoid

Controller directly applies business rules:

```gdscript
func _on_buy_pressed():
	if player.point >= config.cost:
		player.point -= config.cost
		unlocked_items.add(config.id)
```

Prefer:

```gdscript
func _on_buy_pressed():
	GameManager.send_command(BuyItemCommand.new(config))
```

Controller owns refund logic:

```gdscript
func _drop_to_trash(item):
	GameManager.send_command(ChangePointCommand.new(item.cost))
	item.queue_free()
```

Prefer a business Command:

```gdscript
func _drop_to_trash(item):
	GameManager.send_command(RemoveDecorationCommand.new(item))
```

Repeated validation inside multiple Commands:

```gdscript
func _check_buy_result():
	if config.cost > player.point:
		return failed_not_enough_point()
	if queue.size() >= max_count:
		return failed_queue_full()
```

Prefer shared System methods:

```gdscript
var result = shop_sys.check_buy_potion(config)
```

Event chain drives core business:

```text
buy_requested_event -> point_changed_event -> item_unlock_event -> save_requested_event
```

Prefer:

```text
BuyItemCommand -> shopSystem/check -> Model changes -> buy_finished_event
```

## Save Pattern

Use the framework's save Command/System flow instead of direct file writes from UI or gameplay nodes.

Models or Systems that persist data should implement the project's conventions:

- `save_common_data()` / `load_common_data()` for global persistent data.
- `save_level_data()` / `load_level_data()` for level or scene-specific data.
- `save_setting_data()` / `load_setting_data()` for settings if the project has that split.

If file IO grows complex, split technical details into `SaveIO`, `SaveUtility`, or an Autoload while keeping save organization in `SaveSystem`.

## Decision Questions

Ask these before editing:

- Would this logic still be true if the UI changed? If yes, do not put it in Controller.
- Does this affect points, inventory, unlock state, growth, save data, or progression? Use Command/System.
- Will multiple entry points need this rule? Put it in a System.
- Is this only a read-only view projection across Models? Use Query.
- Is this purely technical Godot/platform access? Use Utility/Autoload.

