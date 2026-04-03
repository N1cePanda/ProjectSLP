extends CharacterBody3D

@export var speed: float = 5.0
@export var speed_multiplyer: float = 2.0
const JUMP_VELOCITY: float = 4.5
var remaining_jumps: int = 2

@onready var camera: Node3D = $CameraRig/Camera3D

@export var wall_run_speed: float = 7.0
@export var wall_gravity: float = 2.0
@export var wall_check_distance: float = 1.2
@export var wall_run_duration: float = 5.0
var wall_run_timer: float = 0.0
var is_wall_running: bool = false
var wall_normal: Vector3 = Vector3.ZERO
var can_wall_run: bool = true

@export var dash_speed: float = 25.0
@export var dash_time: float = 0.35
@export var dash_cooldown: float = 0.5
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var can_dash: bool = true

func _physics_process(delta: float) -> void:
	var grounded: bool = is_on_floor()
	if grounded:
		can_dash = true
		can_wall_run = true
		wall_run_timer = 1.0
		remaining_jumps = 2

	if not grounded and not is_wall_running:
		velocity += get_gravity() * delta

	var direction: Vector3 = get_input_direction()

	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		is_dashing = true
		dash_timer = dash_time
		dash_cooldown_timer = dash_cooldown
		dash_direction = direction
		can_dash = false

	var current_speed: float = speed
	if Input.is_action_pressed("Sprint"):
		current_speed *= speed_multiplyer

	if not is_dashing and not is_wall_running:
		if direction != Vector3.ZERO:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_speed)
			velocity.z = move_toward(velocity.z, 0.0, current_speed)

	if is_dashing:
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

	if Input.is_action_just_pressed("ui_accept") and remaining_jumps > 0:
		remaining_jumps -= 1
		velocity.y = JUMP_VELOCITY

	check_wall()
	if is_wall_running and wall_run_timer > 0.0:
		wall_run_timer -= delta
		remaining_jumps = 2
		var wall_direction: Vector3 = wall_normal.cross(Vector3.UP).normalized()
		if wall_direction.dot(get_input_direction()) < 0:
			wall_direction = -wall_direction
		velocity += wall_normal * 0.1
		velocity.x = wall_direction.x * wall_run_speed
		velocity.z = wall_direction.z * wall_run_speed
		velocity.y = lerp(velocity.y, -wall_gravity, 0.2)
		can_wall_run = false

	move_and_slide()
	turn_to(direction)

func turn_to(direction: Vector3) -> void:
	if direction != Vector3.ZERO:
		var yaw: float = atan2(-direction.x, -direction.z)
		yaw = lerp_angle(rotation.y, yaw, 0.1)
		rotation.y = yaw

func check_wall() -> void:
	is_wall_running = false
	if is_on_floor() or not can_wall_run:
		return
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision3D = get_slide_collision(i)
		var normal: Vector3 = collision.get_normal()
		if abs(normal.y) < 0.1:
			wall_normal = normal
			is_wall_running = true
			wall_run_timer = wall_run_duration
			break

func get_input_direction() -> Vector3:
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir: Vector3 = (camera.global_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if dir == Vector3.ZERO:
		dir = -transform.basis.z
	return Vector3(dir.x, 0.0, dir.z).normalized() * input_dir.length()
