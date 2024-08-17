extends Control

@export var scene_to_load_on_play: PackedScene

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(scene_to_load_on_play)

func _on_quit_pressed() -> void:
	get_tree().quit()
