extends Node2D

func _process(delta: float) -> void:
	# Make sure the uniform exists on the shader and is a float
	if material.get_shader_parameter("scale") is float:
		# Get the current zoom of the camera
		var screen_zoom:float = get_viewport().get_camera_2d().zoom.x
		# The scale is the current camera zoom
		material.set_shader_parameter("scale", 1.0/screen_zoom)
