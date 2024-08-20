extends Node

var music_volume: float = 1
var sound_fx_volume: float = 1

var toggle_fullscreen: int = DisplayServer.WINDOW_MODE_WINDOWED

var current_level: int = 0

func set_music_volume():
	var music_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(
		music_index,
		linear_to_db(music_volume)
	)
	
func set_sfx_volume():
	var sfx_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(
		sfx_index,
		linear_to_db(sound_fx_volume)
	)
	
func set_fullscreen():
	DisplayServer.window_set_mode(toggle_fullscreen)
	
func persist_save_data() -> void:
	var save_dict := {}
	save_dict["music_volume"] = music_volume
	save_dict["sound_fx_volume"] = sound_fx_volume
	save_dict["toggle_fullscreen"] = toggle_fullscreen
	save_dict["current_level"] = current_level
	
	var save_file := FileAccess.open("user://save_data", FileAccess.WRITE)
	save_file.store_var(save_dict)
	save_file.close()

func load_save_data() -> void:
	if !FileAccess.file_exists("user://save_data"):
		# If the game has not yet been saved, leave values as default
		return
	
	var save_file := FileAccess.open("user://save_data", FileAccess.READ)
	var save_dict:Dictionary = save_file.get_var()
	
	music_volume = save_dict["music_volume"]
	sound_fx_volume = save_dict["sound_fx_volume"]
	toggle_fullscreen = save_dict["toggle_fullscreen"]
	current_level = save_dict["current_level"]
	
	set_music_volume()
	set_sfx_volume()
	set_fullscreen()
