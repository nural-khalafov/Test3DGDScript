class_name PlayerController extends CharacterBody3D

@export_category("Player Camera Settings")
@export var mouse_sensitivity : float = 0.25
@export var camera_follow_speed : float = 20.0

@export_category("Node Components")
@export var crouch_shapecast : ShapeCast3D
@export var collision_shape3d : CollisionShape3D
@export var head_node : Node3D

# Camera tilt constant variables
const TILT_MIN_LIMIT := deg_to_rad(-75.0)
const TILT_MAX_LIMIT := deg_to_rad(75.0)

var lean_blend_target : float = 1.0
var lean_blend_position : String = "parameters/LeanBlendSpace1D/blend_position"

var aim_idle_fov : float = 90.0
var aim_idle_position : Vector3 = Vector3(0.192, -0.236, 0.151)
var aim_firing_position : Vector3 = Vector3(0.037, -0.191, 0.221)
var aim_firing_fov : float = 60.0

var mouse_input : bool = false
var rotation_input : float
var tilt_input : float
var mouse_rotation : Vector3
var player_rotation : Vector3
var camera_rotation : Vector3

var menu_toggled : bool = false

var input_direction

@onready var animation_tree : AnimationTree = $"AnimationTree"
@onready var animation_player : AnimationPlayer = $"AnimationPlayer"
@onready var skeleton : Skeleton3D = $"Armature/Skeleton3D"
@onready var camera : Camera3D = $"Head/Camera3D"
@onready var ik_effector : GodotIKEffector = $"Armature/Skeleton3D/GodotIK/GodotIKEffector"
@onready var head_target : Marker3D = $"Armature/Skeleton3D/HeadPoint/Head_Target"

@onready var right_hand_ik : SkeletonIK3D = $"Armature/Skeleton3D/RightHandIK"
@onready var left_hand_ik : SkeletonIK3D = $"Armature/Skeleton3D/LeftHandIK"
@onready var aim_target : Node3D = $"Head/Camera3D/Target"

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init() -> void:
	Global.player = self
	DebugGlobals.player = self

func _ready() -> void:
	# get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x * mouse_sensitivity
		tilt_input = -event.relative.y * mouse_sensitivity

func _physics_process(_delta: float) -> void:
	# update camera movement based on mouse movement
	update_camera(_delta)
	update_camera_follow(_delta)
	update_aiming(_delta)
	# add crouch check shapecast collision exception for CharacterBody3D node
	crouch_shapecast.add_exception($".")

# Camera movement logic
func update_camera(_delta: float):
	mouse_rotation.x += tilt_input * _delta
	mouse_rotation.x = clamp(mouse_rotation.x, TILT_MIN_LIMIT, TILT_MAX_LIMIT)
	mouse_rotation.y += rotation_input * _delta

	player_rotation = Vector3(0.0, mouse_rotation.y, 0.0)
	camera_rotation = Vector3(mouse_rotation.x, 0.0, 0.0)

	camera.transform.basis = Basis.from_euler(camera_rotation)
	global_transform.basis = Basis.from_euler(player_rotation)

	camera.rotation.z = 0.0

	rotation_input = 0.0
	tilt_input = 0.0

func update_gravity(_delta) -> void:
	velocity.y -= gravity * _delta

func update_input(_speed: float, _acceleration: float, _deceleration: float) -> void:
	# get the input direction and handle the movement/deceleration
	
	var direction = (transform.basis * Vector3(get_input_direction().x, 0, get_input_direction().y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * _speed, _acceleration)
		velocity.z = lerp(velocity.z, direction.z * _speed, _acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, _deceleration)
		velocity.z = move_toward(velocity.z, 0, _deceleration)

func get_input_direction() -> Vector2:
	input_direction = Input.get_vector("left", "right", "up", "down")
	return input_direction

func update_velocity() -> void:
	move_and_slide()

# Leaning logic
func update_leaning(_can_lean: bool, _delta: float) -> void:
	if _can_lean:
		if Input.is_action_pressed("lean_left"):
			ik_effector.rotation.z = lerpf(ik_effector.rotation.z, -2.5, _delta * 5)
		elif Input.is_action_pressed("lean_right"):
			ik_effector.rotation.z = lerpf(ik_effector.rotation.z, 2.5, _delta * 5)
		else:
			ik_effector.rotation.z = lerpf(ik_effector.rotation.z, 0.0, _delta * 5)
	else:
		pass

func update_camera_follow(_delta: float) -> void:
	var desired_position = head_target.global_transform.origin
	camera.global_transform.origin = camera.global_transform.origin.lerp(desired_position, camera_follow_speed * _delta)
	right_hand_ik.start()
	left_hand_ik.start()

func update_aiming(_delta: float) -> void:
	if Input.is_action_pressed("aim"):
		aim_target.position = aim_target.position.lerp(aim_firing_position, _delta * 8)
		camera.fov = 60
	if Input.is_action_just_released("aim"):
		aim_target.position = aim_idle_position
		camera.fov = 90
