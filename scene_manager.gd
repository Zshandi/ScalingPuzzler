extends Node

@export
var default_scene:PackedScene

var current_scene_packed:PackedScene

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func change_scene_to_node(scene_node:Node, reset_packed := true):
	if reset_packed: current_scene_packed = null
	scene_node.visible = false
	var add_to := get_tree().root
	
	var switch_to_scene := func():
		var current_scene := get_tree().current_scene
		add_to.add_child(scene_node)
		scene_node.owner = add_to
		# TODO Transition
		
		#get_tree().paused = true
		#scene_node.modulate = Color.TRANSPARENT
		scene_node.visible = true
		#var tween := create_tween()
		#tween.tween_property(scene_node, "modulate", Color.WHITE, 1)
		#tween.parallel().tween_property(current_scene, "modulate", Color.TRANSPARENT, 1)
		#tween.play()
		#await tween.finished
		#get_tree().paused = false
		
		if current_scene != null:
			current_scene.visible = false
			# Unload current scene
			current_scene.get_parent().remove_child(current_scene)
			current_scene.queue_free()
		get_tree().current_scene = scene_node
	
	if add_to.is_node_ready():
		switch_to_scene.call()
	else:
		switch_to_scene.call_deferred()

func change_scene_to_packed(scene:PackedScene) -> void:
	current_scene_packed = scene
	var instanced_scene := scene.instantiate()
	change_scene_to_node(instanced_scene, false)

func change_scene_to_file(file:String) -> void:
	var loaded_file := load(file)
	assert(loaded_file is PackedScene, "Cannot change scene to file because it is not a scene: " + file)
	if loaded_file is PackedScene:
		change_scene_to_packed(loaded_file)
