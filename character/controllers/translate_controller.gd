extends ControllerBase
class_name TranslateController

@export
var translation_line_color := Color.WHITE
@export
var translation_line_width:float = 3.0

@export
var translation_min_distance:float = 70
@export
var translation_max_distance:float = 500
@export
var translation_min_force:float = 200
@export
var translation_max_force:float = 800

@export
var translation_upward_boost = 1200
@export
var translation_upward_boost_duration = 1

var translate_line:CappedLine

var collision_shape:CollisionShape2D

var upward_boost_remaining:float = 0.0

var normals:Array[Vector2]

func _ready():
	collision_shape = owner.find_child("CollisionShape2D")
	translate_line = CappedLine.create(Vector2.ZERO, Vector2.ZERO, translation_line_width, translation_line_color, true)
	translate_line.visible = false
	collision_shape.add_child(translate_line)
	translate_line.owner = get_tree().root

func _physics_process(delta):
	if Input.is_action_pressed("control_translate_activate"):
		var cursor_pos := get_cursor_pos()
		var center_to_cursor_local:Vector2 = (cursor_pos - global_position) / collision_shape.scale
		
		var dist := center_to_cursor_local.length()
		dist = clampf(dist, translation_min_distance, translation_max_distance)
		center_to_cursor_local = center_to_cursor_local.normalized() * dist
		
		var dist_normalized := (dist - translation_min_distance) / (translation_max_distance - translation_min_distance)
		var force_magnitude := lerpf(translation_min_force, translation_max_force, dist_normalized)
		var force = center_to_cursor_local.normalized() * force_magnitude
		
		# Apply boost if on floor
		var is_on_floor := false
		for normal in normals:
			if abs(normal.angle_to(Vector2.UP)) < PI/4:
				is_on_floor = true
				break
		if is_on_floor:
			upward_boost_remaining = translation_upward_boost_duration
		elif upward_boost_remaining > 0:
			upward_boost_remaining -= delta
		if true:#upward_boost_remaining > 0 && center_to_cursor_local.y < 0:
			var boost_magnitude:float = lerpf(0, translation_upward_boost, dist_normalized) * (upward_boost_remaining / translation_upward_boost_duration) ** 2
			var boost_total := center_to_cursor_local.normalized() * boost_magnitude
			var boost_upward := boost_total.project(Vector2.UP)
			force += boost_upward
		
		apply_force(force)
		
		translate_line.from = center_to_cursor_local.normalized() * (translation_min_distance - 10)
		translate_line.to = center_to_cursor_local
		translate_line.rotation = -rotation
		translate_line.visible = true
	else:
		translate_line.visible = false

func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	normals = get_contact_normals(character_state)

func get_cursor_pos() -> Vector2:
	return get_global_mouse_position()
