extends Control

@onready var main_settings := $MainSettings
@onready var graphics_settings := $GraphicsSettings
@onready var sounds_settings := $SoundsSettings

@onready var volume_slider = $SoundsSettings/VolumeSlider
@onready var sfx_slider = $SoundsSettings/SFXSlider

@onready var music_player:AudioStreamPlayer = $AudioStreamPlayer

var music_index: int
var sfx_index: int

@onready var full_screen_btn:Button = $GraphicsSettings/FullscreenButton
@onready var antialiasing_btn:Button = $GraphicsSettings/AnialiasingButton

var full_screen_text:String
var antialiasing_text:String

func _ready() -> void:
	# Sounds setup
	
	music_index = AudioServer.get_bus_index("Music")
	sfx_index = AudioServer.get_bus_index("SFX")
	
	volume_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sound_fx_volume)
	
	default_music_volume = music_player.volume_db
	
	# Graphics setup
	full_screen_text = full_screen_btn.text
	antialiasing_text = antialiasing_btn.text
	
	full_screen_btn.button_pressed = Settings.toggle_fullscreen
	antialiasing_btn.button_pressed = Settings.antialiasing_enabled
	set_toggle_text(full_screen_btn, full_screen_text)
	set_toggle_text(antialiasing_btn, antialiasing_text)

func set_toggle_text(btn:Button, text:String):
	if btn.button_pressed:
		text += "Enabled"
	else:
		text += "Disabled"
	btn.text = text

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	Settings.toggle_fullscreen = toggled_on
	set_toggle_text(full_screen_btn, full_screen_text)

func _on_anialiasing_button_toggled(toggled_on: bool) -> void:
	Settings.antialiasing_enabled = toggled_on
	set_toggle_text(antialiasing_btn, antialiasing_text)

func _on_back_button_pressed() -> void:
	Settings.persist_save_data()
	if main_settings.visible:
		get_tree().change_scene_to_file("res://title_screen.tscn")
	else:
		main_settings.visible = true
		graphics_settings.visible = false
		sounds_settings.visible = false
		if music_fade_tween != null:
			music_fade_tween.stop()
			music_fade_tween = null
			music_player.stop()

var default_music_volume:float
var music_fade_tween:Tween
func _on_volume_slider_value_changed(value: float) -> void:
	Settings.music_volume = value
	
	# Play music, but fade after 5 seconds
	if music_fade_tween != null:
		music_fade_tween.stop()
	
	music_player.volume_db = default_music_volume
	if !music_player.playing:
		music_player.play()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_interval(5)
	music_fade_tween.tween_property(music_player, "volume_db", -60, 1)
	music_fade_tween.tween_callback(func(): music_player.stop())
	music_fade_tween.play()

func _on_sfx_slider_value_changed(value: float) -> void:
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


func _on_clear_save_pressed() -> void:
	Settings.current_level = 0
	Settings.persist_save_data()


func _on_graphics_button_pressed() -> void:
	graphics_settings.visible = true
	main_settings.visible = false


func _on_sounds_button_pressed() -> void:
	sounds_settings.visible = true
	main_settings.visible = false
