extends RigidBody2D
class_name Ball

@export
var movement_controller_0:ControllerBase
@export
var movement_controller_1:ControllerBase
@export
var movement_controller_2:ControllerBase

var current_movement_controller:ControllerBase

@export
## The standard set of controllers which will always be active
var standard_controllers:Array[ControllerBase] = []

# Active controllers are separated from the "standard" ones:
#  Standard are always active, but not all active ones will be standard
var active_controllers:Array[ControllerBase] = []

func _ready():
	for controller in standard_controllers:
		active_controllers.push_back(controller)
	
	current_movement_controller = movement_controller_2
	active_controllers.push_back(current_movement_controller)
	
	for controller in active_controllers:
		controller._ready_set_owner(self)

func _process(delta):
	for controller in active_controllers:
		controller._process(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event:InputEventKey = event
		var switch_movement:ControllerBase = null
		
		match key_event.keycode:
			KEY_0:
				switch_movement = movement_controller_0
			KEY_1:
				switch_movement = movement_controller_1
			KEY_2:
				switch_movement = movement_controller_2
		
		if switch_movement != null:
			# Disable current active controller
			var current_movement_controller_idx := active_controllers.find(current_movement_controller)
			if current_movement_controller_idx >= 0:
				active_controllers.remove_at(current_movement_controller_idx)
			
			# Activate new one
			current_movement_controller = switch_movement
			active_controllers.push_back(current_movement_controller)
			current_movement_controller._ready_set_owner(self)

func _physics_process(delta):
	for controller in active_controllers:
		controller._physics_process(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	for controller in active_controllers:
		controller._integrate_forces(character_state)
