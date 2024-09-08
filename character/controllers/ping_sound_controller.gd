extends ControllerBase
class_name PingSoundController

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

var last_velocity:Vector2

func _on_ready():
	last_velocity = linear_velocity

func _physics_process(delta) -> void:
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
