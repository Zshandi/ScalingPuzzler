extends Node2D

func _process(delta: float) -> void:
	var screen_zoom:float = get_viewport().get_camera_2d().zoom.x
	material.set_shader_parameter("scale", 1.0/screen_zoom)
