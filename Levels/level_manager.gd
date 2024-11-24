extends Node

var level_order: Array[PackedScene] = preload("res://resources/level_order.tres").level_order

func set_level_relative(level_index_offset:int):
	set_level(Settings.current_level+level_index_offset)

func set_level(level_index:int):
	if level_index < 0: level_index = 0
	if level_index >= len(level_order):
		SceneManager.change_scene_to_file("res://game_complete.tscn", SceneTransition.FADE_WHITE)
		Settings.current_level = 0
		Settings.persist_save_data()
	else:
		Settings.current_level = level_index
		Settings.persist_save_data()
		SceneManager.change_scene_to_packed(level_order[level_index], SceneTransition.DEFAULT)
