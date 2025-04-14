class_name WalkingPlayerState extends PlayerMovementState

const SPEED : float = 5.0
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

const HEAD_WALK_POSITION : float = -0.37
const DEFAULT_HEAD_HEIGHT : float = 1.8

const walk_blend_position : String = "parameters/PlayerStateMachine/Standing/WalkBlendSpace2D/blend_position"

func update(_delta):
	player_controller.update_input(SPEED, ACCELERATION, DECELERATION)

	player_controller.head_node.position = Vector3(0.0, DEFAULT_HEAD_HEIGHT, HEAD_WALK_POSITION)

	player_controller.animation_tree.set(walk_blend_position, 
	Vector2(player_controller.get_input_direction().x, -player_controller.get_input_direction().y))

	if player_controller.velocity.length() == 0.0 and player_controller.is_on_floor():
		transition.emit("IdlePlayerState")

	if Input.is_action_pressed("sprint") and player_controller.is_on_floor():
		transition.emit("SprintingPlayerState")

	if Input.is_action_just_pressed("crouch") and player_controller.is_on_floor():
		transition.emit("CrouchingPlayerState")

	if Input.is_action_just_pressed("jump") and player_controller.is_on_floor():
		transition.emit("JumpingPlayerState")

	if player_controller.velocity.y > -3.0 and !player_controller.is_on_floor():
		transition.emit("FallingPlayerState")

func physics_update(_delta):
	player_controller.update_gravity(_delta)
	player_controller.update_velocity()
	player_controller.update_leaning(true, _delta)