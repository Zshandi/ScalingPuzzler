extends Node2D

@export
## The amount scaled per scroll
var scale_step := 0.3
@export
## The strength of the scale smoothing
## Note that this corresponds to an exponential decay from the current scale to the target,
##  meaning it is not really an exact speed, but rather just determines how steep the decay is,
##  but the exact speed will be dependent on the current distance to the target
var scale_strength := 5.0
@export
var max_scale_speed := 0.2

@export
## The node to apply transform controls to by default
var transform_target:Transformable

# Called when the node enters the scene tree for the first time.
func _ready():
	# Assumes equal x and y scale
	assert(transform_target.global_transform.get_scale().x ==
		transform_target.global_transform.get_scale().y)
	target_scale = transform_target.get_current_linear_scale()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_scaling(delta)
	handle_translation(delta)
	handle_rotation(delta)

#var original_scale := 0.0

var target_scale:float = 0.0
var scale_direction:int = 0
var scale_origin := Vector2.ZERO

## Temporary HACK until we actually stop the ball from clipping in #4 (https://github.com/Zshandi/ScalingPuzzler/issues/4)
var min_scale := -1.2

func handle_scaling(delta):
	var current_scale:float = transform_target.get_current_linear_scale()
	
	if Input.is_action_just_pressed("control_scale_up"):
		target_scale += scale_step
		scale_origin = get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("control_scale_down"):
		target_scale -= scale_step
		scale_origin = get_viewport().get_mouse_position()
	
	if target_scale != current_scale:
		var target_scale_direction = 1 if target_scale > 0 else -1
		
		# Get new scale (exp decay to target)
		var scale_to := lerpf(current_scale, target_scale, delta * scale_strength)
		
		## Temporary HACK until we actually stop the ball from clipping in #4 (https://github.com/Zshandi/ScalingPuzzler/issues/4)
		if scale_to < min_scale:
			scale_to = min_scale
			target_scale = min_scale
		
		# Scale to that scale
		var scale_by := scale_to - current_scale
		
		# Limit scaling speed
		scale_by = max(-max_scale_speed, scale_by)
		scale_by = min(max_scale_speed, scale_by)
		
		transform_target.linear_scale_from(scale_origin, scale_by)

func handle_translation(delta):
	pass

func handle_rotation(delta):
	pass
