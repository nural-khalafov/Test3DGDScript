class_name SprintingPlayerState extends PlayerMovementState

const SPEED : float = 8.5
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

const sprint_blend_position : String = "parameters/PlayerStateMachine/Standing/RunBlendSpace1D/blend_position"

func update(delta):
	player_controller.update_gravity(delta)
	player_controller.update_input(SPEED, ACCELERATION, DECELERATION)
	player_controller.update_velocity()
    
	player_controller.animation_tree.is_sprinting = true
	player_controller.animation_tree.set(sprint_blend_position, SPEED)

	if player_controller.velocity.length() == 0.0 and player_controller.is_on_floor():
		player_controller.animation_tree.is_sprinting = false
		transition.emit("IdlePlayerState")

	if Input.is_action_just_released("sprint") and player_controller.is_on_floor():
		player_controller.animation_tree.is_sprinting = false
		transition.emit("WalkingPlayerState")

	if Input.is_action_just_pressed("jump") and player_controller.is_on_floor():
		player_controller.animation_tree.is_sprinting = false
		transition.emit("JumpingPlayerState")
		
