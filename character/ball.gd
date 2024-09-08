extends RigidBody2D
class_name Ball

@export
## The standard set of controllers which will always be active
var standard_controllers:Array[ControllerBase] = []

# Active controllers are separated from the "standard" ones:
#  Standard are always active, but not all active ones will be standard
var active_controllers:Array[ControllerBase] = []

func _ready():
	for controller in standard_controllers:
		active_controllers.push_back(controller)
	
	for controller in active_controllers:
		controller._ready_set_owner(self)

func _process(delta):
	for controller in active_controllers:
		controller._process(delta)

func _physics_process(delta):
	for controller in active_controllers:
		controller._physics_process(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(character_state: PhysicsDirectBodyState2D) -> void:
	for controller in active_controllers:
		controller._integrate_forces(character_state)
