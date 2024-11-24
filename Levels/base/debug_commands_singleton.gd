extends Node

func _ready() -> void:
	var dbg_node = preload("res://debug_commands.tscn").instantiate()
	
	add_child(dbg_node)
	dbg_node.owner = self
