extends CharacterBody3D


@export_category("Player Controller Settings")
@export var is_crouch_toggled : bool = true

@export_category("Camera Settings")
@export var mouse_sensitivity : float = 0.25
@export var tilt_lower_limit := deg_to_rad(-90.0)
@export var tilt_upper_limit := deg_to_rad(90.0)

@export_category("Components")
@export var animation_player : AnimationPlayer
@export var crouch_shapecast : Node3D

@export_category("Animation Controller Settings")
@export_range(5, 10, 0.1) var crouch_playbackspeed : float = 7.0

const DEFAULT_SPEED : float = 5.0
const CROUCH_SPEED : float = 2.0
const SPRINT_SPEED : float = 8.5
const JUMP_VELOCITY : float = 4.5
const ACCELERATION : float = 0.1
const DECELERATION : float = 0.25

var _speed : float
var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var _is_crouching : bool = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

	#Global.player = self
	#DebugGlobals.player = self

	# get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# set default speed
	_speed = DEFAULT_SPEED

	# add crouch check shapecast collision exception for CharacterBody3D node
	crouch_shapecast.add_exception($".")

func _unhandled_input(event: InputEvent) -> void:

	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	if event.is_action_pressed("crouch") and is_on_floor():
		toggle_crouch()

	if event.is_action_pressed("crouch") and _is_crouching == false and is_on_floor() and is_crouch_toggled == false:
		crouching(true)

	if event.is_action_released("crouch") and is_crouch_toggled == false and is_on_floor():
		if crouch_shapecast.is_colliding() == false:
			crouching(false)
		elif crouch_shapecast.is_colliding() == true:
			uncrouch_check()

	if event.is_action_pressed("sprint") and is_on_floor() and _is_crouching == false:
		set_movement_speed("sprinting")
	if event.is_action_released("sprint") and _is_crouching == false:
		set_movement_speed("default")

func _physics_process(delta: float) -> void:
	# add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# update camera movement based on mouse movement
	_update_camera(delta)

	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and _is_crouching == false:
		velocity.y = JUMP_VELOCITY

	# get the input direction and handle the movement/deceleration
	var input_dir = Input.get_vector("left", "right", "up", "down")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * _speed, ACCELERATION)
		velocity.z = lerp(velocity.z, direction.z * _speed, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.z = move_toward(velocity.z, 0, DECELERATION)

	move_and_slide()

func _update_camera(delta: float):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, tilt_lower_limit, tilt_upper_limit)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	%Camera3D.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	%Camera3D.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func crouching(state: bool):
	match state:
		true:
			animation_player.play("Crouch", 0, crouch_playbackspeed)
			set_movement_speed("crouching")
		false:
			animation_player.play("Crouch", 0, -crouch_playbackspeed, true)
			set_movement_speed("default")

func uncrouch_check():
	if crouch_shapecast.is_colliding() == false:
		crouching(false)
	if crouch_shapecast.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch_check()

func toggle_crouch():
	if _is_crouching == true and crouch_shapecast.is_colliding() == false:
		crouching(false)
	elif _is_crouching == false:
		crouching(true)

func set_movement_speed(state: String):
	match state:
		"default":
			_speed = DEFAULT_SPEED
		"crouching":
			_speed = CROUCH_SPEED
		"sprinting":
			_speed = SPRINT_SPEED

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "Crouch":
		_is_crouching = !_is_crouching
