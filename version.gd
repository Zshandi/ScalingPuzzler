extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var version = ProjectSettings.get_setting("application/config/version")
	#if OS.is_debug_build():
		# TODO: Grt commit number and append it for ease
		# Will need to run git rev-parse --short HEAD on command-line during build and store somewhere accessible here
	
	text = "Version " + version
