class_name PlayerController extends CharacterBody3D

@export_category("Player Controller Settings")

@export_category("Player Camera Settings")
@export var mouse_sensitivity : float = 0.25

@export_category("Node Components")
@export var animation_player : AnimationPlayer
@export var crouch_shapecast : ShapeCast3D

# Camera tilt constant variables
const TILT_MIN_LIMIT := deg_to_rad(-90.0)
const TILT_MAX_LIMIT := deg_to_rad(90.0)

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var menu_toggled : bool = false

var input_direction

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine_playback : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init() -> void:
	Global.player = self
	DebugGlobals.player = self

func _ready() -> void:
	# get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# add crouch check shapecast collision exception for CharacterBody3D node
	crouch_shapecast.add_exception($".")

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:
	# update camera movement based on mouse movement
	_update_camera(delta)


func _update_camera(delta: float):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_MIN_LIMIT, TILT_MAX_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	%Camera3D.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	%Camera3D.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func update_gravity(delta) -> void:
	velocity.y -= gravity * delta

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	# get the input direction and handle the movement/deceleration
	
	var direction = (transform.basis * Vector3(get_input_direction().x, 0, get_input_direction().y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)

func get_input_direction() -> Vector2:
	input_direction = Input.get_vector("left", "right", "up", "down")
	return input_direction

func update_velocity() -> void:
	move_and_slide()
