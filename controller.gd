extends Node2D

## The amount scaled per scroll
@export
var scale_step := 0.3
## The strength of the scale smoothing
## Note that this corresponds to an exponential decay from the current scale to the target,
##  meaning it is not really an exact speed, but rather just determines how steep the decay is,
##  but the exact speed will be dependent on the current distance to the target
@export
var scale_strength := 5.0
@export
var max_scale_speed := 0.2

@export
## The strength of the scale smoothing
## Note that this corresponds to an exponential decay from the current scale to the target,
##  meaning it is not really an exact speed, but rather just determines how steep the decay is,
##  but the exact speed will be dependent on the current distance to the target
var translation_strength:float = 10.0
@export
var max_translation_speed:float = 20

@export
var translation_line_color := Color.WHITE
@export
var translation_line_width:float = 3.0

@export
## The node to apply transform controls to by default
var transform_target:Transformable

@export
## The node that represents the character to reach the goal
var character:Ball

var translate_line:CappedLine

# Called when the node enters the scene tree for the first time.
func _ready():
	# Assumes equal x and y scale
	assert(transform_target.global_transform.get_scale().x ==
		transform_target.global_transform.get_scale().y)
	target_scale = transform_target.get_current_linear_scale()
	
	translate_target = transform_target.global_position
	
	translate_line = CappedLine.create(Vector2.ZERO, Vector2.ZERO, translation_line_width, translation_line_color, true)
	translate_line.visible = false
	get_tree().root.add_child(translate_line)
	translate_line.owner = get_tree().root

func _physics_process(delta):
	pass
	#handle_scaling(delta)
	#handle_translation(delta)
	#handle_rotation(delta)

var target_scale:float = 0.0
var scale_direction:int = 0
var scale_origin := Vector2.ZERO

func handle_scaling(delta):
	var current_scale:float = transform_target.get_current_linear_scale()
	
	if Input.is_action_just_pressed("control_scale_up"):
		target_scale += scale_step
		scale_origin = get_cursor_pos()
	if Input.is_action_just_pressed("control_scale_down"):
		target_scale -= scale_step
		scale_origin = get_cursor_pos()
	
	if target_scale != current_scale:
		var target_scale_direction = 1 if target_scale > 0 else -1
		
		# Get new scale (exp decay to target)
		var scale_to := lerpf(current_scale, target_scale, delta * scale_strength)
		
		if character.is_between_walls && target_scale - current_scale < 0:
			scale_to = current_scale
			target_scale = current_scale
		
		# Scale to that scale
		var scale_by := scale_to - current_scale
		
		# Limit scaling speed
		scale_by = max(-max_scale_speed, scale_by)
		scale_by = min(max_scale_speed, scale_by)
		
		# un-transform translate_target to account for scaling
		translate_target = transform_target.to_local(translate_target)
		translate_origin_offset = transform_target.to_local(translate_origin_offset + transform_target.global_position)
		
		transform_target.linear_scale_from(scale_origin, scale_by)
		
		# re-transform translate_target to account for scaling
		translate_target = transform_target.to_global(translate_target)
		translate_origin_offset = transform_target.to_global(translate_origin_offset) - transform_target.global_position

var is_translating_pressed:bool = false
var is_translating:bool = false
var translate_origin_offset := Vector2.ZERO
var translate_target := Vector2.ZERO

func handle_translation(delta):
	var cursor_pos := get_cursor_pos()
	var translate_current := transform_target.global_position
	
	if Input.is_action_pressed("control_translate_activate"):
		translate_line.visible = true
		is_translating = true
		if !is_translating_pressed:
			# Setup the offset to start with
			translate_origin_offset = cursor_pos - transform_target.global_position
			is_translating_pressed = true
		
		translate_target = cursor_pos
	else:
		is_translating_pressed = false
	
	var offset_to_cursor := translate_target - (translate_current + translate_origin_offset)
	
	var translate_by := Vector2.ZERO.lerp(offset_to_cursor, delta * translation_strength)
	
	var translate_by_length := translate_by.length()
	
	if translate_by_length > max_translation_speed:
		translate_by = translate_by.normalized() * max_translation_speed
	
	if translate_by_length < 0.1 or not is_translating:
		translate_by = Vector2.ZERO
		is_translating = false
	else:
		transform_target.global_transform = transform_target.global_transform.translated(translate_by)
	
	if translate_by != Vector2.ZERO && translate_line.visible:
		translate_line.from = translate_current + translate_origin_offset
		translate_line.to = translate_target
	else:
		translate_line.visible = false

func handle_rotation(delta):
	pass

func get_cursor_pos() -> Vector2:
	return get_viewport().get_mouse_position() + get_viewport().get_camera_2d().global_position
