extends Node

var music_volume: float = 1 :
	get: return music_volume
	set(value):
		music_volume = value
		apply_music_volume_setting()

var sound_fx_volume: float = 0.8 :
	get: return sound_fx_volume
	set(value):
		sound_fx_volume = value
		apply_sfx_volume_setting()

var toggle_fullscreen: bool = false :
	get: return toggle_fullscreen
	set(value):
		toggle_fullscreen = value
		apply_fullscreen_setting()

var antialiasing_enabled: bool = true :
	get: return antialiasing_enabled
	set(value):
		antialiasing_enabled = value
		apply_antialiasing_setting()

var current_level: int = 0

func apply_music_volume_setting():
	var music_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(
		music_index,
		linear_to_db(music_volume)
	)
	
func apply_sfx_volume_setting():
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(
		sfx_index,
		linear_to_db(sound_fx_volume)
	)
	
func apply_fullscreen_setting():
	if toggle_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func apply_antialiasing_setting():
	RenderingServer.global_shader_parameter_set("antialiasing_enabled", antialiasing_enabled)

func persist_save_data() -> void:
	var save_dict := {}
	save_dict["music_volume"] = music_volume
	save_dict["sound_fx_volume"] = sound_fx_volume
	save_dict["toggle_fullscreen"] = toggle_fullscreen
	save_dict["current_level"] = current_level
	save_dict["antialiasing_enabled"] = antialiasing_enabled
	
	var save_file := FileAccess.open("user://save_data", FileAccess.WRITE)
	save_file.store_var(save_dict)
	save_file.close()

func load_save_data() -> void:
	if !FileAccess.file_exists("user://save_data"):
		# If the game has not yet been saved, leave values as default
		apply_music_volume_setting()
		apply_sfx_volume_setting()
		apply_fullscreen_setting()
		apply_antialiasing_setting()
		return
	
	var save_file := FileAccess.open("user://save_data", FileAccess.READ)
	var save_dict:Dictionary = save_file.get_var()
	
	music_volume = save_dict["music_volume"]
	sound_fx_volume = save_dict["sound_fx_volume"]
	toggle_fullscreen = save_dict["toggle_fullscreen"]
	current_level = save_dict["current_level"]
	if save_dict.has("antialiasing_enabled"):
		antialiasing_enabled = save_dict["antialiasing_enabled"]
	
	print_debug("antialiasing_enabled: ", antialiasing_enabled)
