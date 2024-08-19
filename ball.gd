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


var is_between_walls:bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	check_between_walls(character_state)
	process_ping_sound(character_state)
	

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

func process_ping_sound(character_state: PhysicsDirectBodyState2D) -> void:
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
