extends Control

signal command_received(cmd_name:String, cmd_args:Array[String])

@onready
var command_prompt := $VBoxContainer/CommandPrompt
@onready
var command_output := $VBoxContainer/CommandOutput

func write_line(output:String):
	command_output.text += output + "\n"

func process_command(command: String):
	print_debug("Received command: ", command)
	
	var cmd_args:Array[String]
	cmd_args.assign(command.split(" ", false))
	var cmd_name := cmd_args[0]
	cmd_args.pop_front()
	
	command_received.emit(cmd_name, cmd_args)
	
	write_line("/" + command)
	
	var error:String = ""
	
	match cmd_name:
		"setlevel":
			if cmd_args.size() != 1 or !cmd_args[0].is_valid_int():
				error = "setlevel requires exactly one integer parameter"
			else:
				$"../..".set_level(cmd_args[0].to_int())
		"setlevelrelative":
			if cmd_args.size() != 1 or !cmd_args[0].is_valid_int():
				error = "setlevelrelative requires exactly one integer parameter"
			else:
				$"../..".set_level_relative(cmd_args[0].to_int())
		_:
			error = "'" + cmd_name + "' is not recognized as a command"
	
	
	if error != "":
		write_line("ERROR: " + error)
		command_prompt.text = "/"
		command_prompt.caret_column = 1
	else:
		set_prompt_enabled(false)
		command_prompt.clear()
		command_prompt.release_focus()

func _ready() -> void:
	set_prompt_enabled(false)

func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action("debug_command_open"):
		set_prompt_enabled(true)
		command_prompt.grab_focus()
	
	if event.is_action("ui_cancel"):
		set_prompt_enabled(false)
		command_prompt.clear()
		command_prompt.release_focus()

func set_prompt_enabled(enabled:bool):
	command_prompt.editable = enabled
	command_prompt.selecting_enabled = enabled
	visible = enabled

func _on_command_prompt_text_submitted(new_text: String) -> void:
	var command := new_text.trim_prefix("/")
	process_command(command)
