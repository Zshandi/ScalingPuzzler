extends RigidBody2D
class_name Ball

@export
## Angle (in radians) to determine if the ball is squished between 2 walls
## Essentially it's the minimum angle the 2 walla need to be to each other to be considered "squished"
## Defaulting to slightly less than a half turn
var adjascent_wall_angle := PI * 0.9

## Minimum impulse to cause a ping sound
## Note that this is based on current gravity and mass,
##  but was determined through testing
@export
var accel_ping_threshold:float = 25
## Impulse which corresponds to the max ping volume
@export
var accel_ping_max:float = 200

## Minimum ping volume gain, in Db
@export
var min_ping_gain:float = -10
## Maximum ping volume gain, in Db
@export
var max_ping_gain:float = -3

## Minimum ping pitch scale
@export
var min_ping_pitch:float = 0.8
## Maximum ping pitch scale
@export
var max_ping_pitch:float = 1.2

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
var translation_line_color := Color.WHITE
@export
var translation_line_width:float = 3.0

var translate_line:CappedLine
var is_between_walls:bool

func _ready():
	translate_line = CappedLine.create(Vector2.ZERO, Vector2.ZERO, translation_line_width, translation_line_color, true)
	translate_line.visible = false
	get_tree().root.add_child(translate_line)
	translate_line.owner = get_tree().root
	
	target_scale = get_current_linear_scale()

func _physics_process(delta):
	handle_scaling(delta)
	handle_translation(delta)
	handle_rotation(delta)
	
	process_ping_sound()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	check_between_walls(character_state)

func check_between_walls(character_state: PhysicsDirectBodyState2D) -> void:
	var max_angle := 0.0
	var normals : Array[Vector2] = []
	
	for i in range(0, character_state.get_contact_count()):
		var normal = character_state.get_contact_local_normal(i)
		for prev_normal in normals:
			var angle = abs(normal.angle_to(prev_normal))
			if angle > max_angle:
				max_angle = angle
		normals.push_back(normal)
	
	is_between_walls = max_angle > adjascent_wall_angle

@onready
var last_velocity := linear_velocity

func process_ping_sound() -> void:
	var accel_magnitude := (linear_velocity - last_velocity).length()
	last_velocity = linear_velocity
	
	if accel_magnitude > accel_ping_threshold:
		## Scale the value between threshold and max to be between 0 and 1
		var progress := (accel_magnitude - accel_ping_threshold) / (accel_ping_max - accel_ping_threshold)
		progress = clampf(progress, 0, 1)
		
		var ping_gain := lerpf(min_ping_gain, max_ping_gain, progress)
		
		var ping_pitch := randf_range(min_ping_pitch, max_ping_pitch)
		
		# Create instance of bounce stream player
		# Having separate instances for each play allows for their ring to overlap,
		#  so when one plays it doesn't cut off the previous one
		var stream_player = preload("res://assets/sfx/bounce_stream_player.tscn").instantiate()
		add_child(stream_player)
		stream_player.owner = get_tree().root
		
		stream_player.volume_db = ping_gain
		stream_player.pitch_scale = ping_pitch
		stream_player.play()
		
		# Make sure we remove the player after, so no memory leak
		stream_player.finished.connect(func(): stream_player.queue_free())

var target_scale:float = 0.0
var scale_origin := Vector2.ZERO

func get_current_linear_scale():
	return based_log(2, $CollisionShape2D.transform.get_scale().length())

func handle_scaling(delta:float) -> void:
	var current_scale:float = get_current_linear_scale()
	scale_origin = get_viewport().get_camera_2d().get_screen_center_position()
	
	if Input.is_action_just_pressed("control_scale_up"):
		target_scale -= scale_step
	if Input.is_action_just_pressed("control_scale_down"):
		target_scale += scale_step
	
	if target_scale != current_scale:
		var target_scale_direction = 1 if target_scale > 0 else -1
		
		# Get new scale (exp decay to target)
		var scale_to := lerpf(current_scale, target_scale, delta * scale_strength)
		
		if is_between_walls && target_scale - current_scale < 0:
			scale_to = current_scale
			target_scale = current_scale
		
		# Scale to that scale
		var scale_by_linear := scale_to - current_scale
		
		# Limit scaling speed
		scale_by_linear = max(-max_scale_speed, scale_by_linear)
		scale_by_linear = min(max_scale_speed, scale_by_linear)
		
		var scale_by := pow(2, scale_by_linear)
		var scale_by_vec := Vector2(scale_by, scale_by)
		
		for child in get_children():
			child.transform = child.transform.scaled(scale_by_vec)
		
		var camera = get_viewport().get_camera_2d()
		
		camera.zoom /= scale_by

func handle_translation(delta:float) -> void:
	pass

func handle_rotation(delta:float) -> void:
	pass

# Utility helper function, may want to move to static library
func based_log(base:float = 10, x:float = 10) -> float:
	return (log(x) / log(base))
