class_name PlayerController extends CharacterBody3D

@export_category("Player Camera Settings")
@export var mouse_sensitivity : float = 0.25

@export_category("Node Components")
@export var crouch_shapecast : ShapeCast3D
@export var collision_shape3d : CollisionShape3D
@export var head_node : Node3D

# Camera tilt constant variables
const TILT_MIN_LIMIT := deg_to_rad(-90.0)
const TILT_MAX_LIMIT := deg_to_rad(90.0)

var lean_blend_target : float = 1.0
var lean_blend_position : String = "parameters/LeanBlendSpace1D/blend_position"

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3

var menu_toggled : bool = false

var input_direction

@onready var animation_tree : AnimationTree = $"AnimationTree"
@onready var animation_player : AnimationPlayer = $"AnimationPlayer"
@onready var skeleton : Skeleton3D = $"Armature/Skeleton3D"
@onready var camera : Camera3D = $"Head/Camera3D"
@onready var ik_effector : GodotIKEffector = $"Armature/Skeleton3D/GodotIK/GodotIKEffector"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init() -> void:
	Global.player = self
	DebugGlobals.player = self

func _ready() -> void:
	# get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity

func _physics_process(delta: float) -> void:
	# update camera movement based on mouse movement
	_update_camera(delta)
	# add crouch check shapecast collision exception for CharacterBody3D node
	crouch_shapecast.add_exception($".")

	#update_weapon_hold_anims()


func _update_camera(delta: float):
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_MIN_LIMIT, TILT_MAX_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)

	camera.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	camera.rotation.z = 0.0

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

func update_leaning(_can_lean: bool, _delta: float) -> void:
	if _can_lean:
		if Input.is_action_pressed("lean_left"):
			ik_effector.rotation.z = lerpf(ik_effector.rotation.z, -1.9, _delta * 5)
		elif Input.is_action_pressed("lean_right"):
			ik_effector.rotation.z = lerpf(ik_effector.rotation.z, 1.9, _delta * 5)
		else:
			ik_effector.rotation.z = lerpf(ik_effector.rotation.z, 0.0, _delta * 5)

	else:
		pass
