extends Node2D

@export
## The distance which corresponds to doubling or halving the scale
var scale_factor := 500.0

@export
## The node to apply transform controls to by default
var transform_target:Transformable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	handle_scaling(delta)
	handle_translation(delta)
	handle_rotation(delta)

var scale_origin := Vector2.ZERO
var original_scale := 0.0
var is_scaling := false

func handle_scaling(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var current_cursor_pos := get_viewport().get_mouse_position()
		if !is_scaling:
			scale_origin = current_cursor_pos
			# Assumes equal x and y scale
			assert(transform_target.global_transform.get_scale().x ==
				transform_target.global_transform.get_scale().y)
			original_scale = transform_target.get_current_linear_scale()
			is_scaling = true
		else:
			var scale_distance := -(current_cursor_pos.y - scale_origin.y) / scale_factor
			
			var current_scale:float = transform_target.get_current_linear_scale()
			
			var current_distance := current_scale - original_scale
			
			var distance_to_go := scale_distance - current_distance
			
			transform_target.linear_scale_from(scale_origin, distance_to_go)
	else:
		is_scaling = false

func handle_translation(delta):
	pass

func handle_rotation(delta):
	pass
