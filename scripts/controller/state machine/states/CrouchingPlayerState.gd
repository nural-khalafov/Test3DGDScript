class_name CrouchingPlayerState extends PlayerMovementState

const SPEED : float = 3.0
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

const DEFAULT_HEIGHT : float = 2.15
const CROUCH_HEIGHT : float = 1.6
const HEAD_POSITION : float = -0.27
const DEFAULT_HEAD_HEIGHT : float = 1.8
const CROUCH_HEAD_HEIGHT : float = 1.2

var crouch_blend_position: String = "parameters/PlayerStateMachine/Crouched/CrouchingBlendSpace2D/blend_position"
var walk_blend_position: String = "parameters/PlayerStateMachine/Standing/WalkBlendSpace2D/blend_position"

func update(delta) -> void:
	player_controller.update_gravity(delta)
	player_controller.update_input(SPEED, ACCELERATION, DECELERATION)
	player_controller.update_velocity()

	player_controller.animation_tree.is_crouched = true
	set_camera_collision(true)

	player_controller.animation_tree.set(crouch_blend_position, 
	Vector2(player_controller.get_input_direction().x, -player_controller.get_input_direction().y))


	if Input.is_action_just_released("crouch"):
		uncrouch()

func uncrouch():
	if player_controller.crouch_shapecast.is_colliding() == false and Input.is_action_just_pressed("crouch") == false:
		player_controller.animation_tree.set(walk_blend_position, Vector2.ZERO)
		player_controller.animation_tree.is_crouched = false
		set_camera_collision(false)
		transition.emit("IdlePlayerState")
	elif player_controller.crouch_shapecast.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch()

func set_camera_collision(is_crouching : bool):
	if !is_crouching:
		player_controller.collision_shape3d.shape.height = DEFAULT_HEIGHT
		player_controller.collision_shape3d.position = Vector3(0.0, DEFAULT_HEIGHT / 2, 0.0)
		player_controller.head_node.position = Vector3(0.0, DEFAULT_HEAD_HEIGHT, HEAD_POSITION)
	else:
		player_controller.collision_shape3d.shape.height = CROUCH_HEIGHT
		player_controller.collision_shape3d.position = Vector3(0.0, CROUCH_HEIGHT / 2, 0.0)
		player_controller.head_node.position = Vector3(0.4, CROUCH_HEAD_HEIGHT, HEAD_POSITION - 0.28)


		
