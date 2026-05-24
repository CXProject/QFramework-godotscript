@abstract
class_name AbstractSystem extends Node


@abstract
func init()

@abstract func get_system_name()->String

var architecture:Architecture # system 作为arch里的最上层，应该有直接获取utility和model的能力
