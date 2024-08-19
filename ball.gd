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
var impulse_ping_threshold:float = 25
## Impulse which corresponds to the max ping volume
@export
var impulse_ping_max:float = 150

@export
## Minimum ping volume gain, in Db
var min_ping_gain:float = -10
@export
## Maximum ping volume gain, in Db
var max_ping_gain:float = 10


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

func process_ping_sound(character_state: PhysicsDirectBodyState2D) -> void:
	var total_impulse := Vector2.ZERO
	
	for i in range(0, character_state.get_contact_count()):
		var impulse := character_state.get_contact_impulse(i)
		total_impulse += impulse
	
	var impulse_magnitude := total_impulse.length()
	
	if impulse_magnitude > impulse_ping_threshold:
		print_debug("impulse_magnitude: ", impulse_magnitude)
		## Scale the value between threshold and max to be between 0 and 1
		var progress := (impulse_magnitude - impulse_ping_threshold) / (impulse_ping_max - impulse_ping_threshold)
		progress = clampf(progress, 0, 1)
		
		var ping_gain := lerpf(min_ping_gain, max_ping_gain, progress)
		
		print_debug("ping_gain: ", ping_gain)
		
