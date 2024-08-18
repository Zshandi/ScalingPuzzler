extends Camera2D

@export
var pan_max_speed := 50.0
@export
var pan_accel := 35.0
@export
var pan_brake := 45.0

var pan_speed := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var x_pan := Input.get_axis("camera_pan_left", "camera_pan_right")
	var y_pan := Input.get_axis("camera_pan_up", "camera_pan_down")
	
	adjust_pan_axis(x_pan, Vector2.AXIS_X, delta)
	adjust_pan_axis(y_pan, Vector2.AXIS_Y, delta)
	
	global_position += pan_speed

func adjust_pan_axis(pan_axis_val:float, pan_axis:int, delta:float):
	var target_speed := pan_axis_val * pan_max_speed
	
	var accel := pan_accel
	if target_speed == 0:
		accel = pan_brake
	elif (target_speed < 0) != (pan_speed[pan_axis] < 0):
		accel += pan_brake
	
	pan_speed[pan_axis] = move_toward(pan_speed[pan_axis], target_speed, accel * delta)
