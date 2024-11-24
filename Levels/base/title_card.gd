extends Control
class_name TitleCard

@onready var name_label = $MarginContainer/VBoxContainer/LevelName
@onready var description_label = $MarginContainer/VBoxContainer/LevelDescription
@onready var animation_player = $AnimationPlayer

func update_name_label(level_name: String) -> void:
	name_label.text = level_name
	
func update_description_label(description: String) -> void:
	description_label.text = description

func _ready() -> void:
	show()
	modulate = Color.TRANSPARENT
	animation_player.play("fadein")
	$FadeoutTimer.start()


func _on_fadeout_timer_timeout() -> void:
	animation_player.play("fadeout")
