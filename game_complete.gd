extends Control


func _on_return_pressed() -> void:
	SceneManager.change_scene_to_file("res://title_screen.tscn", SceneTransition.DEFAULT)
