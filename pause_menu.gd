extends Control

func _ready() -> void:
	size = get_viewport_rect().size
	visible = false

func _process(delta: float) -> void:
	# In case the tree is paused for some other reason
	if get_tree().paused and not visible: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_to_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://title_screen.tscn")


func _on_restart_level_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
