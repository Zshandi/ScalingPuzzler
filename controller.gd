extends Node2D

@export
## The distance which corresponds to doubling or halving the scale
var scale_factor := 500.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var scale_origin := Vector2.ZERO
var original_scale := 0.0
var is_scaling := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var current_cursor_pos := get_viewport().get_mouse_position()
		if !is_scaling:
			scale_origin = current_cursor_pos
			# Assumes equal x and y scale
			assert($ScalableRoomInner.global_transform.get_scale().x ==
				$ScalableRoomInner.global_transform.get_scale().y)
			original_scale = $ScalableRoomInner.get_current_linear_scale()
			is_scaling = true
		else:
			var scale_distance := -(current_cursor_pos.y - scale_origin.y) / scale_factor
			
			var current_scale:float = $ScalableRoomInner.get_current_linear_scale()
			
			var current_distance := current_scale - original_scale
			
			var distance_to_go := scale_distance - current_distance
			
			$ScalableRoomInner.linear_scale_from(scale_origin, distance_to_go)
	else:
		is_scaling = false
