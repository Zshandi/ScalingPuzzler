extends Camera2D

@export
var pan_max_speed:float = 50.0
@export
var pan_accel:float = 35.0
@export
var pan_brake:float = 45.0

@export
var pan_center_duration:float = 1.0
@export
var pan_center_trans := Tween.TRANS_CUBIC

var pan_speed := Vector2.ZERO

var pan_to_center:bool = false

var current_center_pan_tween:Tween = null

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("camera_pan_center"):
		if current_center_pan_tween != null:
			current_center_pan_tween.stop()
		pan_to_center = true
		
		var pan_to:Vector2 = $"../Ball".global_position - get_viewport_rect().size / 2
		
		current_center_pan_tween = create_tween()
		current_center_pan_tween.set_trans(pan_center_trans)
		current_center_pan_tween.tween_property(self, "global_position", pan_to, pan_center_duration)
		current_center_pan_tween.tween_property(self, "pan_to_center", false, 0.0)
		current_center_pan_tween.play()
	
	if !pan_to_center:
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
