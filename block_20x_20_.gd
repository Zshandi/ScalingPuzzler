extends CollisionShape2D

@onready var block_texture: TextureRect = $TextureRect

func _ready() -> void:
	_update_texture_rect_size()
	
func _update_texture_rect_size():
	block_texture.size = shape.extents * 2
	print(block_texture.size)
	print(block_texture.position)
	print("\n")
	
	block_texture.position = Vector2(
		(block_texture.size.x/2)*-1,
		(block_texture.size.y/2)*-1
	)
