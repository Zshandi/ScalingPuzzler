extends Node2D
class_name Transformable


func get_current_linear_scale(axis:int = Vector2.AXIS_X) -> float:
	return Util.based_log(2, global_transform.get_scale()[axis])

func linear_scale_from(center:Vector2, linear_scale_by:float):
	# Convenience: go from float to vector
	linear_scale_from_vec(center, Vector2.ONE * linear_scale_by)

func linear_scale_from_vec(center:Vector2, linear_scale_by:Vector2):
	# Convert linear to exponential scaling:
	# 0 = 1x, 1 = 2x, 2 = 4x, -1 = 0.5x, etc.
	var scale_by := Vector2(pow(2, linear_scale_by.x), pow(2, linear_scale_by.y))
	scale_from_vec(center, scale_by)

func scale_from(center:Vector2, scale_by:float):
	# Convenience: go from float to vector
	scale_from_vec(center, Vector2.ONE * scale_by)

func scale_from_vec(center:Vector2, scale_by:Vector2):
	# Get original transform for reference
	var original_transform := global_transform
	
	# Simply scale the transform to start
	var scaled_transform := original_transform.scaled(scale_by)
	
	# Get scaled center position:
	#  1. apply inverse of original transform to get center with no transform (i.e. Identity)
	#  2. apply new transform to get new center
	var adjusted_center := scaled_transform * (original_transform.affine_inverse() * center)
	
	# Get the difference from original center, so we can counteract this in the final transform
	var center_offset := adjusted_center - center
	
	# Subtract the offset, to counter center point movement from scaling
	global_transform = scaled_transform.translated(-center_offset)
