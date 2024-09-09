extends Resource
class_name ControllerBase

var is_ready := false

var owner:RigidBody2D

func _ready_set_owner(set_owner:RigidBody2D):
	if owner != set_owner:
		is_ready = true
		owner = set_owner
		_ready()

func _ready() -> void:
	pass

func _process(delta:float) -> void:
	pass

func _physics_process(delta:float) -> void:
	pass

func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	pass

# Utility function(s)

func get_contact_normals(character_state: PhysicsDirectBodyState2D) -> Array[Vector2]:
	var normals:Array[Vector2] = []
	for i in range(0, character_state.get_contact_count()):
		var normal = character_state.get_contact_local_normal(i)
		normals.push_back(normal)
	return normals

# Implement some common node functionality to reduce effort to adapt code

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

func get_tree():
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
