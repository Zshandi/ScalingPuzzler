extends ParallaxBackground

@export
var background: Texture2D
@export
var scrolling_speed: Vector2 = Vector2(50,50)

@onready var scrolling_sprite = $ParallaxLayer/Sprite2D
@onready var parallax_layer = $ParallaxLayer
@onready var background_sprite = $ParallaxLayer/Sprite2D

func _ready():
	scrolling_sprite.texture = background
	
	var sprite_width = scrolling_sprite.texture.get_width()
	var sprite_height = scrolling_sprite.texture.get_height()
	
	var width_scale_multiplier = floor((200.0 / sprite_width) * 15)
	var height_scale_multiplier = floor((200.0 / sprite_height) * 15)

	var size_to_use = Vector2(
		sprite_width*width_scale_multiplier,
		sprite_height*height_scale_multiplier
	)
	
	scrolling_sprite.region_rect.size = size_to_use
	parallax_layer.motion_mirroring = size_to_use
	
func _process(delta):
	background_sprite.region_rect.position += delta * scrolling_speed
