extends Resource
class_name ControllerBase

var is_ready := false

var owner:RigidBody2D

# This should never be overridden in child class
func _ready_set_owner(set_owner:RigidBody2D) -> void:
	if owner != set_owner:
		is_ready = true
		owner = set_owner
		_ready()

# These should be overridden in child, similar to Node
# Note though, unlike in Node, you should call base._func()

# Called once when the owner is _ready
# May be called multiple times as owners are freed etc.
func _ready() -> void:
	pass

# Called as idle/render frame, delta is dependent on framerate
func _process(delta:float) -> void:
	pass

# Called per physics tick, delta is always constant
func _physics_process(delta:float) -> void:
	pass

# Override to modify or inspect the PhysicsDirectBodyState2D
#  during physics processing
func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	pass

# Utility function(s)

func get_contact_normals(character_state: PhysicsDirectBodyState2D) -> Array[Vector2]:
	var normals:Array[Vector2] = []
	for i in range(0, character_state.get_contact_count()):
		var normal = character_state.get_contact_local_normal(i)
		normals.push_back(normal)
	return normals

# Common Node functionality that calls into owner funcs and vars

var global_position : Vector2:
	get: return owner.global_position
var position : Vector2:
	get: return owner.position

var global_transform : Transform2D:
	get: return owner.global_transform
var transform : Transform2D:
	get: return owner.transform

var global_rotation : float:
	get: return owner.global_rotation
var rotation : float:
	get: return owner.rotation

var linear_velocity : Vector2:
	get: return owner.linear_velocity

var angular_velocity : float:
	get: return owner.angular_velocity

func get_tree() -> SceneTree:
	return owner.get_tree()

func add_child(node: Node, force_readable_name: bool = false, internal: Node.InternalMode = 0) -> void:
	owner.add_child(node, force_readable_name, internal)

func apply_force(force: Vector2, position: Vector2 = Vector2(0, 0)) -> void:
	owner.apply_force(force, position)

func apply_impulse(impulse: Vector2, position: Vector2 = Vector2(0, 0)) -> void:
	owner.apply_impulse(impulse, position)

func get_global_mouse_position() -> Vector2:
	return owner.get_global_mouse_position()

func get_node(path:NodePath) -> Node:
	return owner.get_node(path)
