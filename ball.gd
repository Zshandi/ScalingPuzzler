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
var max_ping_gain:float = 5

## Minimum ping pitch scale
@export
var min_ping_pitch:float = 0.8
## Maximum ping pitch scale
@export
var max_ping_pitch:float = 1.2

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
var is_between_walls:bool

func _ready():
	translate_line = CappedLine.create(Vector2.ZERO, Vector2.ZERO, translation_line_width, translation_line_color, true)
	translate_line.visible = false
	$CollisionShape2D.add_child(translate_line)
	translate_line.owner = get_tree().root

func _physics_process(delta):
	handle_translation(delta)
	handle_rotation(delta)
	
	process_ping_sound()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	check_between_walls(character_state)

var normals : Array[Vector2] = []
func check_between_walls(character_state: PhysicsDirectBodyState2D) -> void:
	var max_angle := 0.0
	normals.clear()
	
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

var upward_boost_remaining:float = 0.0

func handle_translation(delta:float) -> void:
	if Input.is_action_pressed("control_translate_activate"):
		var cursor_pos := get_cursor_pos()
		var center_to_cursor_local:Vector2 = (cursor_pos - global_position) / $CollisionShape2D.scale
		
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

func handle_rotation(delta:float) -> void:
	pass



func get_cursor_pos() -> Vector2:
	return get_global_mouse_position()
