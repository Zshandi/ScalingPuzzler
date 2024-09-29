extends Control

signal command_received(cmd_name:String, cmd_args:Array[String])

@onready
var command_prompt := $VBoxContainer/CommandPrompt
@onready
var command_output := $VBoxContainer/ScrollContainer/CommandOutput
@onready
var scroll := $VBoxContainer/ScrollContainer

var command_history:Array[String] = []
var command_history_none:String = ""

func write_line(output:String):
	command_output.text += output + "\n"
	await get_tree().create_timer(0).timeout
	scroll.get_v_scroll_bar().value = scroll.get_v_scroll_bar().max_value

func process_command(command: String):
	print_debug("Received command: ", command)
	
	var cmd_args:Array[String]
	cmd_args.assign(command.split(" ", false))
	var cmd_name := ""
	if (cmd_args.size() > 0):
		cmd_name = cmd_args[0].to_lower()
		cmd_args.pop_front()
	
	command_received.emit(cmd_name, cmd_args)
	
	var error:String = ""
	
	match cmd_name:
		"setlevel":
			if cmd_args.size() != 1 or !cmd_args[0].is_valid_int():
				error = "setlevel requires exactly one integer parameter"
			else:
				# TODO: Don't rely on position in tree here
				$"../..".set_level(cmd_args[0].to_int())
		"setlevelrelative":
			if cmd_args.size() != 1 or !cmd_args[0].is_valid_int():
				error = "setlevelrelative requires exactly one integer parameter"
			else:
				# TODO: Don't rely on position in tree here
				$"../..".set_level_relative(cmd_args[0].to_int())
		"help":
			# TODO: Better help system
			write_line("Available commands: setlevel, setlevelrelative")
			return
		_:
			error = "'" + cmd_name + "' is not recognized as a command. Need /help?"
	
	if error != "":
		write_line("ERROR: " + error)
	else:
		set_prompt_enabled(false)
		command_prompt.release_focus()

func _ready() -> void:
	set_prompt_enabled(false)

func _input(event: InputEvent) -> void:
	if !OS.is_debug_build(): return
	
	if event.is_action("debug_command_open") and !visible:
		set_prompt_enabled(true)
		command_prompt.grab_focus()
		get_viewport().set_input_as_handled()
	
	if event.is_action("ui_cancel") and visible:
		await get_tree().create_timer(0).timeout
		set_prompt_enabled(false)
		command_prompt.clear()
		command_history_none = ""
		command_prompt.release_focus()
	
	if Input.is_action_just_pressed("ui_up") and visible:
		navigate_history(1)
		get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("ui_down") and visible:
		navigate_history(-1)
		get_viewport().set_input_as_handled()

func navigate_history(by:int):
	var current_index := command_history.find(command_prompt.text)
	if (command_prompt.text == "" and command_history_none != ""):
		current_index = -2
	
	var new_index := clampi(current_index + by, -2, command_history.size()-1)
	
	if current_index == new_index: return
	if current_index == -1:
		command_history_none = command_prompt.text
	
	if new_index == -1:
		command_prompt.text = command_history_none
	elif new_index == -2:
		command_prompt.text = ""
	else:
		command_prompt.text = command_history[new_index]
	
	command_prompt.caret_column = command_prompt.text.length()

func set_prompt_enabled(enabled:bool):
	command_prompt.editable = enabled
	command_prompt.selecting_enabled = enabled
	visible = enabled
	process_mode = PROCESS_MODE_ALWAYS if enabled else PROCESS_MODE_INHERIT
	get_tree().paused = enabled

func _on_command_prompt_text_submitted(new_text: String) -> void:
	write_line(new_text)
	command_prompt.clear()
	# Add history, but ensure no duplicates or empty
	if new_text != "":
		var recent_entry = command_history.find(new_text)
		if (recent_entry != -1): command_history.remove_at(recent_entry)
		command_history.push_front(new_text)
	command_history_none = ""
	
	var command := new_text.trim_prefix("/")
	process_command(command)
