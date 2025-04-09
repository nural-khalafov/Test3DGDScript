class_name JumpingPlayerState extends PlayerMovementState

const SPEED : float = 7
const ACCELERATION : float = 0.015
const DECELERATION : float = 0.1
const JUMP_VELOCITY : float = 5.5
@export_range(0.5, 1.0, 0.01) var input_multiplier : float = 0.85

const jump_blend_position : String = "parameters/PlayerStateMachine/Standing/JumpBlendSpace1D/blend_position"

func enter(previous_state) -> void:
    player_controller.velocity.y += JUMP_VELOCITY
    player_controller.animation_tree.is_in_air = true
    player_controller.animation_tree.set(jump_blend_position, 1.0)


func update(delta):
    player_controller.update_gravity(delta)
    player_controller.update_input(SPEED * input_multiplier, ACCELERATION, DECELERATION)
    player_controller.update_velocity()

    if Input.is_action_just_released("jump"):
        if player_controller.velocity.y > 0:
            player_controller.velocity.y = player_controller.velocity.y / 2.0

    if player_controller.is_on_floor():
        player_controller.animation_tree.is_in_air = false
        transition.emit("IdlePlayerState")