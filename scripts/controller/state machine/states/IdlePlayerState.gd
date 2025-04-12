class_name IdlePlayerState extends PlayerMovementState

const SPEED : float = 5.0
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

const HEAD_IDLE_POSITION : float = -0.3
const DEFAULT_HEAD_HEIGHT : float = 1.8

const walk_blend_position : String = "parameters/PlayerStateMachine/Standing/WalkBlendSpace2D/blend_position"

func update(delta):
	player_controller.update_gravity(delta)
	player_controller.update_input(SPEED, ACCELERATION, DECELERATION)
	player_controller.update_velocity()
	player_controller.update_leaning(true)

	player_controller.head_node.position = Vector3(0.0, DEFAULT_HEAD_HEIGHT, HEAD_IDLE_POSITION)

	player_controller.animation_tree.set(walk_blend_position, Vector2.ZERO)

	if Input.is_action_just_pressed("crouch") and player_controller.is_on_floor():
		transition.emit("CrouchingPlayerState")

	if player_controller.velocity.length() > 0.0 and player_controller.is_on_floor():
		transition.emit("WalkingPlayerState")

	if Input.is_action_just_pressed("jump") and player_controller.is_on_floor():
		transition.emit("JumpingPlayerState")

	if player_controller.velocity.y > -3.0 and !player_controller.is_on_floor():
		transition.emit("FallingPlayerState")
