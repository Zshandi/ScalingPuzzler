extends ParallaxBackground

@export
var background: Texture2D

@export
var scrolling_speed: Vector2 = Vector2(50,50)

@onready var scrolling_sprite = $ParallaxLayer/Sprite2D
@onready var parallax_layer = $ParallaxLayer

@onready var background_sprite = $ParallaxLayer/Sprite2D
@onready var color_rect = $ParallaxLayer2/ColorRect

func _ready():
	scrolling_sprite.texture = background
	
	var sprite_width = scrolling_sprite.texture.get_width()
	var sprite_height = scrolling_sprite.texture.get_height()
	
	var size_to_use = Vector2(
		sprite_width*4,
		sprite_height*4
	)
	
	scrolling_sprite.region_rect.size = size_to_use
	parallax_layer.motion_mirroring = size_to_use
	parallax_layer.position = Vector2(
		sprite_width*2,
		sprite_height*2
	)
	
	

func _process(delta):
	background_sprite.region_rect.position += delta * scrolling_speed
