class_name FallingPlayerState extends PlayerMovementState

const SPEED: float = 5.0
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

const jump_blend_position : String = "parameters/PlayerStateMachine/Standing/JumpBlendSpace1D/blend_position"

func update(delta: float) -> void:
	player_controller.update_gravity(delta)
	player_controller.update_input(SPEED,ACCELERATION,DECELERATION)
	player_controller.update_velocity()

	if !player_controller.is_on_floor():
		player_controller.animation_tree.is_in_air = true
		player_controller.animation_tree.set(jump_blend_position, -1.0)

	if player_controller.is_on_floor():
		player_controller.animation_tree.is_in_air = false
		transition.emit("IdlePlayerState")
