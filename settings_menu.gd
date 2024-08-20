extends Control

@onready var full_screen_btn = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/FullscreenButton
@onready var volume_slider = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/VolumeSlider
@onready var sfx_slider = $MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/SFXSlider

var music_index: int
var sfx_index: int

func _on_fullscreen_button_pressed() -> void:
	var mode = DisplayServer.window_get_mode()
	
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	Settings.toggle_fullscreen = DisplayServer.window_get_mode()

func _on_back_button_pressed() -> void:
	Settings.persist_save_data()
	get_tree().change_scene_to_file("res://title_screen.tscn")


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		music_index,
		linear_to_db(value)
	)
	Settings.music_volume = value

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		sfx_index,
		linear_to_db(value)
	)
	Settings.sound_fx_volume = value

func _ready() -> void:
	music_index = AudioServer.get_bus_index("Music")
	sfx_index = AudioServer.get_bus_index("SFX")
	volume_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sound_fx_volume


func _on_clear_save_pressed() -> void:
	Settings.current_level = 0
	Settings.persist_save_data()
