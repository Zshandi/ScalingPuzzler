extends Node

@export
var default_scene:PackedScene

var current_scene_packed:PackedScene

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS

func set_visible(node:Node, visible:bool):
	node.visible = visible
	if (node.has_method("set_full_visibility")):
		node.set_full_visibility(visible)

func change_scene_to_node(scene_node:Node, reset_packed := true):
	if reset_packed: current_scene_packed = null
	
	var add_to := get_tree().root
	set_visible(scene_node, false)
	
	var switch_to_scene := func():
		get_tree().paused = true
		var current_scene := get_tree().current_scene
		add_to.add_child(scene_node)
		scene_node.owner = add_to
		# TODO Transition
		
		var transition := SceneTransition.new()
		
		await transition.apply(current_scene, scene_node)
		
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

class SceneTransition:
	var color:Color
	var transparent:Color
	var duration:float
	
	var transition_cover_scene:PackedScene = preload("res://scene_manager_transition_cover.tscn")
	
	func _init(color_:Color = Color.BLACK, duration_:float = 0.5):
		color = color_
		duration = duration_
		
		transparent = Color(color, 0)
	
	## pre-conditions:  to.visible == false and from.visible == true
	## post-conditions: to.visible == true  and from.visible == false
	func apply(from:Node, to:Node):
		SceneManager.get_tree().paused = true
		
		var transition_scene_node:Node = transition_cover_scene.instantiate()
		SceneManager.get_tree().root.add_child(transition_scene_node)
		transition_scene_node.owner = SceneManager.get_tree().root
		
		var transition:ColorRect = transition_scene_node.find_child("ColorRect")
		transition.color = transparent
		
		var tween := SceneManager.create_tween()
		tween.tween_property(transition, "color", color, duration/2)
		tween.tween_callback(func(): SceneManager.set_visible(from, false))
		tween.tween_callback(func(): SceneManager.set_visible(to, true))
		tween.tween_property(transition, "color", transparent, duration/2)
		tween.play()
		await tween.finished
		
		transition_scene_node.queue_free()
		SceneManager.get_tree().paused = false
