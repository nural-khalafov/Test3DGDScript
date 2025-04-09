class_name StateMachine extends Node

@export var current_state : State
var states : Dictionary = {}

func _init() -> void:
	DebugGlobals.player_state_machine = self

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contains incompatible child node")

	await owner.ready
	current_state.enter(null)

func _process(delta: float) -> void:
	current_state.update(delta)

func _physics_process(delta: float) -> void:
	current_state.physics_update(delta)

func on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != current_state:
			current_state.exit()
			new_state.enter(current_state)
			current_state = new_state
	else:
		push_warning("State does not exist")
