class_name QF

static func get_tree()->SceneTree:return Engine.get_main_loop() as SceneTree

static var wait_one_frame:Signal:
	get:return get_tree().process_frame
