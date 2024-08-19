extends Control

@export var scene_to_load_on_play: PackedScene

var level_order: LevelOrder = preload("res://resources/level_order.tres")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(level_order.level_order[0])

func _on_quit_pressed() -> void:
	get_tree().quit()
