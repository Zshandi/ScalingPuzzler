extends ControllerBase
class_name PullLaunchController

@export
var translation_line_color := Color.WHITE
@export
var translation_line_width:float = 9.0

@export
var pullback_min_distance:float = 0
@export
var pullback_max_distance:float = 300
@export
var pullback_min_impulse:float = 50
@export
var pullback_max_impulse:float = 800

var pullback_line:CappedLine

var collision_shape:CollisionShape2D
var collision_radius:float

var is_pullback_active := false

var current_pullback_impulse:Vector2 = Vector2.ZERO

func _ready():
	collision_shape = owner.find_child("CollisionShape2D")
	# Dev Note: Assuming the shape is a circle shape here
	collision_radius = collision_shape.shape.radius
	pullback_min_distance = collision_radius
	
	pullback_line = CappedLine.create(Vector2.ZERO, Vector2.ZERO, translation_line_width, translation_line_color, true)
	pullback_line.visible = false
	collision_shape.add_child(pullback_line)
	pullback_line.owner = get_tree().root

func _physics_process(delta):
	if Input.is_action_just_pressed("control_translate_activate"):
		if get_cursor_pos().distance_to(global_position) <= collision_radius:
			is_pullback_active = true
	
	if Input.is_action_pressed("control_translate_activate") and is_pullback_active:
		var cursor_pos := get_cursor_pos()
		var center_to_cursor_local:Vector2 = (cursor_pos - global_position) / collision_shape.scale
		
		var dist := center_to_cursor_local.length()
		if dist >= pullback_min_distance:
			dist = clampf(dist, pullback_min_distance, pullback_max_distance)
			center_to_cursor_local = center_to_cursor_local.normalized() * dist
			
			var dist_normalized := (dist - pullback_min_distance) / (pullback_max_distance - pullback_min_distance)
			var impulse_magnitude := lerpf(pullback_min_impulse, pullback_max_impulse, dist_normalized)
			current_pullback_impulse = -center_to_cursor_local.normalized() * impulse_magnitude
			
			pullback_line.from = center_to_cursor_local
			pullback_line.to = -center_to_cursor_local
			pullback_line.rotation = -rotation
			pullback_line.visible = true
		else:
			current_pullback_impulse = Vector2.ZERO
			pullback_line.visible = false
	elif is_pullback_active:
		pullback_line.visible = false
		is_pullback_active = false
		if current_pullback_impulse != Vector2.ZERO:
			apply_impulse(current_pullback_impulse)
			current_pullback_impulse = Vector2.ZERO

func get_cursor_pos() -> Vector2:
	return get_global_mouse_position()
