extends Control

var level_order: LevelOrder = preload("res://resources/level_order.tres")

func _ready() -> void:
	Settings.load_save_data()

func _on_play_pressed() -> void:
	SceneManager.change_scene_to_packed(
		level_order.level_order[Settings.current_level],
		SceneTransition.DEFAULT
	)

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	SceneManager.change_scene_to_file("res://settings.tscn")
