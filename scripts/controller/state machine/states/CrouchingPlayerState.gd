class_name CrouchingPlayerState extends PlayerMovementState

const SPEED : float = 3.0
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

var crouch_blend_space : String = "CrouchBlendSpace2D"
var crouch_blend_position: String = "parameters/CrouchBlendSpace2D/blend_position"
var walk_blend_space : String = "WalkBlendSpace2D"
var walk_blend_position: String = "parameters/WalkBlendSpace2D/blend_position"

func enter() -> void:
    pass

func update(delta) -> void:
    player_controller.update_gravity(delta)
    player_controller.update_input(SPEED, ACCELERATION, DECELERATION)
    player_controller.update_velocity()

    player_controller.state_machine_playback.travel(crouch_blend_space)
    player_controller.animation_tree.set(crouch_blend_position, 
    Vector2(player_controller.get_input_direction().x, -player_controller.get_input_direction().y))


    if Input.is_action_just_released("crouch"):
        uncrouch()

func uncrouch():
    if player_controller.crouch_shapecast.is_colliding() == false and Input.is_action_just_pressed("crouch") == false:
        player_controller.state_machine_playback.travel(walk_blend_space)
        player_controller.animation_tree.set(walk_blend_position, Vector2.ZERO)
        transition.emit("IdlePlayerState")
    elif player_controller.crouch_shapecast.is_colliding() == true:
        await get_tree().create_timer(0.1).timeout
        uncrouch()


        