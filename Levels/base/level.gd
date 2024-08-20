extends Node2D
class_name Level

@export
var level_name: String
@export
var level_hint: String
var level_order: LevelOrder = load("res://resources/level_order.tres")
@onready var title_card: TitleCard = $CanvasLayer/TitleCard

func _ready() -> void:
	title_card.update_name_label(level_name)
	title_card.update_description_label(level_hint)
	
	# find all nodes of type goal
	for goal in get_tree().get_nodes_in_group("goal_group"):
		goal.connect("level_complete", _on_level_complete)
		
func _on_level_complete() -> void:
	var i = 0
	var found = false
	# Determine the next level
	for level in level_order.level_order:
		if get_tree().current_scene.scene_file_path == level.resource_path:
			found = true
			break
		i += 1
	
	if found:
		if i >= len(level_order.level_order) - 1:
			get_tree().change_scene_to_file("res://title_screen.tscn")
		else:
			get_tree().change_scene_to_packed(level_order.level_order[i+1])
