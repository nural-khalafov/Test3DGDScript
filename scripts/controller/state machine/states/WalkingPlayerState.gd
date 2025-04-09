class_name WalkingPlayerState extends PlayerMovementState

const SPEED : float = 5.0
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

func enter() -> void:
	pass

func update(delta):
	player_controller.update_gravity(delta)
	player_controller.update_input(SPEED, ACCELERATION, DECELERATION)
	player_controller.update_velocity()

	player_controller.state_machine_playback.travel("WalkBlendSpace2D")
	player_controller.animation_tree.set("parameters/WalkBlendSpace2D/blend_position", 
	Vector2(player_controller.get_input_direction().x, -player_controller.get_input_direction().y))

	if player_controller.velocity.length() == 0.0 and player_controller.is_on_floor():
		transition.emit("IdlePlayerState")

	if Input.is_action_pressed("sprint") and player_controller.is_on_floor():
		transition.emit("SprintingPlayerState")

	if Input.is_action_just_pressed("crouch") and player_controller.is_on_floor():
		transition.emit("CrouchingPlayerState")
