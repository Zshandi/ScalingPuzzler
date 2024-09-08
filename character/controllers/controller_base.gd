extends Resource
class_name ControllerBase

var is_ready := false

var owner:Ball

func _ready_set_owner(set_owner:Ball):
	if not is_ready:
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

# Implement some common node functionality to reduce effort to adapt code

var linear_velocity : Vector2:
	get: return owner.linear_velocity

var angular_velocity : float:
	get: return owner.angular_velocity

func get_tree():
	if owner == null: return null
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
