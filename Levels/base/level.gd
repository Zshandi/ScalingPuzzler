extends Node2D
class_name Level

@export
var level_name: String
@export
var level_hint: String
var level_order: Array[PackedScene] = load("res://resources/level_order.tres").level_order
@onready var title_card: TitleCard = $CanvasLayer/TitleCard

func _ready() -> void:
	title_card.update_name_label(level_name)
	title_card.update_description_label(level_hint)
	
	# find all nodes of type goal
	for goal in get_tree().get_nodes_in_group("goal_group"):
		goal.connect("level_complete", _on_level_complete)
		
func _on_level_complete() -> void:
	LevelManager.set_level_relative(1)

func set_full_visibility(value:bool) -> void:
	visible = value
	$CanvasLayer.visible = value
	$ScrollingBackground.visible = value
