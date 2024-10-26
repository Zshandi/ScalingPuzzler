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

func change_scene_to_node(scene_node:Node, transition:SceneTransition = null, reset_packed := true):
	if reset_packed: current_scene_packed = null
	
	var add_to := get_tree().root
	set_visible(scene_node, false)
	
	var switch_to_scene := func():
		var current_scene := get_tree().current_scene
		add_to.add_child(scene_node)
		scene_node.owner = add_to
		
		# Note: The transition causes the ball to start the level with some movement,
		#  and furthermore this movement seems to depend on previous movement / position
		#  (if you restart, it flips between moving left/right on start)
		# As a current workaround, we can just set the current scene to disabled processing,
		#  but we need to be careful as this may not affect nodes with PROCESS_MODE_PAUSABLE set
		if transition != null:
			current_scene.process_mode = PROCESS_MODE_DISABLED
			await transition.apply(current_scene, scene_node)
		else:
			set_visible(scene_node, true)
		
		if current_scene != null:
			set_visible(current_scene, false)
			# Unload current scene
			current_scene.get_parent().remove_child(current_scene)
			current_scene.queue_free()
		get_tree().current_scene = scene_node
	
	if add_to.is_node_ready():
		switch_to_scene.call()
	else:
		switch_to_scene.call_deferred()

func change_scene_to_packed(scene:PackedScene, transition:SceneTransition = null) -> void:
	current_scene_packed = scene
	var instanced_scene := scene.instantiate()
	change_scene_to_node(instanced_scene, transition, false)

func change_scene_to_file(file:String, transition:SceneTransition = null) -> void:
	var loaded_file := load(file)
	assert(loaded_file is PackedScene, "Cannot change scene to file because it is not a scene: " + file)
	if loaded_file is PackedScene:
		change_scene_to_packed(loaded_file, transition)

func reload_current_scene(transition:SceneTransition = null) -> void:
	assert(current_scene_packed != null)
	if current_scene_packed == null: return
	var instanced_scene := current_scene_packed.instantiate()
	change_scene_to_node(instanced_scene, transition, false)
