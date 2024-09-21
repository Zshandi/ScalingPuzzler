extends Resource
class_name SceneTransition

static var DEFAULT := SceneTransition.new()

static var WHITE := SceneTransition.new(Color.WHITE)
static var LONG := SceneTransition.new(Color.BLACK, 1.5)
static var WHITE_LONG := SceneTransition.new(Color.WHITE, 1.5)

@export
var color:Color
var transparent:Color
@export
var duration:float

var transition_cover_scene:PackedScene = preload("res://scene_manager_transition_cover.tscn")

func _init(color_:Color = Color.BLACK, duration_:float = 0.5):
	color = color_
	duration = duration_
	
	transparent = Color(color, 0)

## pre-conditions:  to.visible == false and from.visible == true
## post-conditions: to.visible == true  and from.visible == false
func apply(from:Node, to:Node):
	var transition_scene_node:Node = transition_cover_scene.instantiate()
	SceneManager.get_tree().root.add_child(transition_scene_node)
	transition_scene_node.owner = SceneManager.get_tree().root
	
	var transition:ColorRect = transition_scene_node.find_child("ColorRect")
	transition.color = transparent
	
	var tween := SceneManager.create_tween()
	tween.tween_property(transition, "color", color, duration/2)
	if from != null:
		tween.tween_callback(func(): SceneManager.set_visible(from, false))
	tween.tween_callback(func(): SceneManager.set_visible(to, true))
	tween.tween_property(transition, "color", transparent, duration/2)
	tween.play()
	await tween.finished
	
	transition_scene_node.queue_free()
