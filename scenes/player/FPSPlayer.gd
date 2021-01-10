class_name FPSPlayer
extends KinematicBody

onready var ground := $Ground as RayCast
onready var ray := $Head/Camera/RayCast as RayCast
onready var head := $Head as Spatial
onready var camera := $Head/Camera as Camera

export(float) var speed := 3.0
export(float) var acceleration := 10.0

var shader : ShaderMaterial
var velocity = Vector3()
var gravity_vector : Vector3 = Vector3.ZERO
var has_control : bool = true
var head_locked : bool = false
var camera_angle : float = 0.0
var mouse_sensitivity : float = -.3

const GRAVITY : float = 10.0;
const MAX_GRAVITY : float = 100.0;
const MAX_SLOP := deg2rad(15.0);

func _ready() -> void:
	shader = $Head/Camera/Shader.mesh.surface_get_material(0) as ShaderMaterial;

func make_current() -> void:
	camera.make_current()

func reset() -> void:
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	zeroed_velocity()
	camera_angle = 0

func zeroed_velocity() -> void:
	velocity = Vector3.ZERO
	gravity_vector = Vector3.ZERO

func _input(event: InputEvent) -> void:
	if not head_locked and event is InputEventMouseMotion:
		head.rotate_y(deg2rad(event.relative.x * mouse_sensitivity))

		var change = event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			camera.rotate_x(deg2rad(change))
			camera_angle = camera_angle + change

func _physics_process(delta: float) -> void:
	var direction := Vector3()
	var aim = camera.get_global_transform().basis

	if has_control:
		if Input.is_action_pressed("move_forward"):
			direction -= aim.z
		if Input.is_action_pressed("move_backward"):
			direction += aim.z
		if Input.is_action_pressed("move_left"):
			direction -= aim.x
		if Input.is_action_pressed("move_right"):
			direction += aim.x

	var dir = Vector2(direction.x, direction.z).normalized()
	velocity.x = lerp(velocity.x, dir.x * speed, acceleration * delta)
	velocity.z = lerp(velocity.z, dir.y * speed, acceleration * delta)

	if not is_on_floor():
		gravity_vector += Vector3.DOWN * GRAVITY * delta
	elif is_on_floor() and ground.is_colliding():
		gravity_vector = -get_floor_normal() * -GRAVITY
	else:
		gravity_vector = -get_floor_normal()

	if gravity_vector.y > MAX_GRAVITY:
		gravity_vector.y = MAX_GRAVITY

	velocity.x += gravity_vector.x
	velocity.y = gravity_vector.y
	velocity.z += gravity_vector.z

	velocity = move_and_slide_with_snap(velocity, Vector3(0, -1, 0), Vector3.UP, true, 4, MAX_SLOP)

func force_move(direction: Vector3) -> void:
	translate(direction)

func force_move_to(spatial: Spatial) -> void:
	global_transform.origin = spatial.global_transform.origin
	rotation = spatial.global_transform.basis.get_euler()
	head.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera_angle = 0.0

func get_trigger_hover() -> Object:
	if ray.is_colliding():
		var collider = ray.get_collider()
		return collider
	return null

func toggle(what: String) -> void:
	var param = '%s_enable' % what
	if what == 'shader':
		param = 'enable'
	var param_value = shader.get_shader_param(param)
	shader.set_shader_param(param, not param_value)
