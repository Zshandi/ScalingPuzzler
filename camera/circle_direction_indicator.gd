extends Node2D

@onready
var cam:Camera2D = $".."

func _process(delta: float) -> void:
	var camera_center := cam.get_screen_center_position()
	var ball_position:Vector2 = cam.ball.global_position
	var camera_to_ball := ball_position - camera_center
	
	transform = Transform2D.IDENTITY.rotated(camera_to_ball.angle())
	
	var rect := Rect2(cam.global_position, get_viewport_rect().size)
	
	var intersection = segment_intersect_rect(camera_center, ball_position, rect)
	
	if intersection is Vector2:
		global_position = intersection

## Note: This is not a general implementation, as it assumes only a single intersection point,
##  so no need to return multiple points or closest point
func segment_intersect_rect(from:Vector2, to:Vector2, rect:Rect2):
	var intersecting_point = null
	
	var rect_top_left := rect.position
	var rect_bottom_right := rect.end
	
	var rect_top_right := Vector2(rect_bottom_right.x, rect_top_left.y)
	var rect_bottom_left := Vector2(rect_top_left.x, rect_bottom_right.y)
	
	intersecting_point = Geometry2D.segment_intersects_segment(rect_top_left, rect_top_right, from, to)
	if intersecting_point != null:
		return intersecting_point
	
	intersecting_point = Geometry2D.segment_intersects_segment(rect_top_right, rect_bottom_right, from, to)
	if intersecting_point != null:
		return intersecting_point
	
	intersecting_point = Geometry2D.segment_intersects_segment(rect_bottom_right, rect_bottom_left, from, to)
	if intersecting_point != null:
		return intersecting_point
	
	return Geometry2D.segment_intersects_segment(rect_bottom_left, rect_top_left, from, to)
	

func _on_camera_area_body_entered(body: Node2D) -> void:
	if body == cam.ball:
		visible = false

func _on_camera_area_body_exited(body: Node2D) -> void:
	if body == cam.ball:
		visible = true
