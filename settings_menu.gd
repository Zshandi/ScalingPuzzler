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
	# Play ping sound, note these should be gotten from ball
	var ping_pitch := randf_range(0.8, 1.2) # Bad hardcoded duplicate
	
	# Create instance of bounce stream player
	# Having separate instances for each play allows for their ring to overlap,
	#  so when one plays it doesn't cut off the previous one
	var stream_player = preload("res://assets/sfx/bounce_stream_player.tscn").instantiate()
	add_child(stream_player)
	stream_player.owner = get_tree().root
	
	stream_player.volume_db = 5 # Bad hardcoded duplicate
	stream_player.pitch_scale = ping_pitch
	stream_player.play()
	
	# Make sure we remove the player after, so no memory leak
	stream_player.finished.connect(func(): stream_player.queue_free())

func _ready() -> void:
	music_index = AudioServer.get_bus_index("Music")
	sfx_index = AudioServer.get_bus_index("SFX")
	volume_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sound_fx_volume


func _on_clear_save_pressed() -> void:
	Settings.current_level = 0
	Settings.persist_save_data()
