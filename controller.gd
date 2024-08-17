extends Node2D

@export
## The distance which corresponds to doubling or halving the scale
var scale_factor := 500.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var original_transform := Transform2D.IDENTITY
var scale_origin := Vector2.ZERO
var local_scale_origin:Vector2
var is_scaling := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var current_cursor_pos := get_viewport().get_mouse_position()
		if !is_scaling:
			scale_origin = current_cursor_pos
			original_transform = $ScalableRoomInner.global_transform
			is_scaling = true
		else:
			var scale_distance := -(current_cursor_pos.y - scale_origin.y) / scale_factor
			var scale_val := pow(2, scale_distance)
			#TODO: Actually change center of scaling
			var scaled_transform := original_transform.scaled(Vector2.ONE * scale_val)
			
			var adjusted_origin := scaled_transform * (original_transform.affine_inverse() * scale_origin)
			
			var origin_offset := adjusted_origin - scale_origin
			
			var final_transform := scaled_transform.translated(-origin_offset)
			
			$ScalableRoomInner.global_transform = final_transform
	else:
		is_scaling = false
