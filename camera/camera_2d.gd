extends Camera2D

@export
var ball:Node2D

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
@export
var pan_center_lock_threshold := 6.0

var pan_speed := Vector2.ZERO

var is_panning_to_center:bool = false
var panning_to_center_target := Vector2.ZERO

var is_center_pan_locked:bool = false

var current_center_pan_tween:Tween = null

func _ready() -> void:
	if ball == null:
		ball = $"../Ball"
	$CameraArea/CollisionShape2D.shape.size = get_viewport_rect().size
	$CameraArea/CollisionShape2D.position = get_viewport_rect().size / 2
	
	is_center_pan_locked = true
	pan_to_center()

func _process(delta: float) -> void:
	
	#if Input.is_action_just_pressed("camera_pan_center_lock"):
		#is_center_pan_locked = not is_center_pan_locked
		#if is_center_pan_locked:
			#pan_to_center()
	#
	#if Input.is_action_just_pressed("camera_pan_center") and not is_center_pan_locked:
		#pan_to_center()
	
	if is_center_pan_locked:
		if is_panning_to_center:
			if panning_to_center_target.distance_squared_to(get_ball_position()) > pan_center_lock_threshold ** 2:
				var time_remaining = pan_center_duration - current_center_pan_tween.get_total_elapsed_time()
				pan_to_center(time_remaining, Tween.EASE_OUT)
		else:
			global_position = get_ball_position()
	
	if not is_panning_to_center and not is_center_pan_locked:
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

func get_ball_position():
	return ball.global_position - get_viewport_rect().size / 2

func pan_to_center(duration:float = pan_center_duration, ease:Tween.EaseType = Tween.EASE_IN_OUT):
	if current_center_pan_tween != null:
		current_center_pan_tween.stop()
	is_panning_to_center = true
	
	panning_to_center_target = get_ball_position()
	
	current_center_pan_tween = create_tween()
	current_center_pan_tween.set_trans(pan_center_trans)
	current_center_pan_tween.set_ease(ease)
	current_center_pan_tween.tween_property(self, "global_position", panning_to_center_target, duration)
	current_center_pan_tween.tween_property(self, "is_panning_to_center", false, 0.0)
	current_center_pan_tween.play()
