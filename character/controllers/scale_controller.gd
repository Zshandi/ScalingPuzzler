extends ControllerBase
class_name ScaleController

## The amount scaled per scroll
@export
var scale_step := 0.25
## The strength of the scale smoothing
## Note that this corresponds to an exponential decay from the current scale to the target,
##  meaning it is not really an exact speed, but rather just determines how steep the decay is,
##  but the exact speed will be dependent on the current distance to the target
@export
var scale_strength := 5.0
@export
var max_scale_speed := 0.2

@export
var transform_target_path:NodePath
## The node to apply transform controls to by default
var transform_target:Transformable

@export
## Angle (in radians) to determine if the ball is squished between 2 walls
## Essentially it's the minimum angle the 2 walla need to be to each other to be considered "squished"
## Defaulting to slightly less than a half turn
var adjascent_wall_angle := PI * 0.9

const scale_margin := 0.005

var target_scale:float = 0.0
var scale_origin := Vector2.ZERO

const min_scale := -3.2
const max_scale := 14.2

var is_between_walls:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	transform_target = get_node(transform_target_path)
	# Assumes equal x and y scale
	assert(transform_target.global_transform.get_scale().x ==
		transform_target.global_transform.get_scale().y)
	target_scale = transform_target.get_current_linear_scale()

func _physics_process(delta):
	super._physics_process(delta)
	scale_origin = global_position
	
	var current_scale:float = transform_target.get_current_linear_scale()
	
	if Input.is_action_just_pressed("control_scale_up"):
		target_scale += scale_step
		#print_debug("target_scale: ", target_scale)
	if Input.is_action_just_pressed("control_scale_down"):
		target_scale -= scale_step
		#print_debug("target_scale: ", target_scale)
	
	target_scale = clamp(target_scale, min_scale, max_scale)
	
	if target_scale != current_scale:
		var scale_to:float
		# Get new scale (exp decay to target)
		if abs(target_scale - current_scale) <= scale_margin:
			scale_to = target_scale
		else:
			scale_to = lerpf(current_scale, target_scale, delta * scale_strength)
		
		if is_between_walls && target_scale - current_scale < 0:
			scale_to = current_scale
			target_scale = current_scale
		
		# Scale to that scale
		var scale_by := scale_to - current_scale
		
		# Limit scaling speed
		scale_by = max(-max_scale_speed, scale_by)
		scale_by = min(max_scale_speed, scale_by)
		
		transform_target.linear_scale_from(scale_origin, scale_by)

func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	check_between_walls(character_state)

func check_between_walls(character_state: PhysicsDirectBodyState2D) -> void:
	var max_angle := 0.0
	
	var prev_normals:Array[Vector2] = []
	
	for normal in get_contact_normals(character_state):
		for prev_normal in prev_normals:
			var angle = abs(normal.angle_to(prev_normal))
			if angle > max_angle:
				max_angle = angle
		prev_normals.push_back(normal)
	
	is_between_walls = max_angle > adjascent_wall_angle
