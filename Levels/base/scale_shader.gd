@tool
extends Node2D

var prev_zoom:float = -1

func _process(delta: float) -> void:
	# Make sure the uniform exists on the shader and is a float
	if material.get_shader_parameter("scale") is float:
		# Get the current zoom of the camera
		var screen_zoom:float = -1
		if get_viewport() != null and get_viewport().get_camera_2d() != null:
			screen_zoom = get_viewport().get_camera_2d().zoom.x
		elif get_viewport() != null and get_viewport().get_final_transform() != null:
			screen_zoom = get_viewport().get_final_transform().x.x
		
		if screen_zoom != prev_zoom and screen_zoom > 0:
			# The scale is the current camera zoom
			material.set_shader_parameter("scale", 1.0/screen_zoom)
			prev_zoom = screen_zoom
