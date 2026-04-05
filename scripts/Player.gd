extends CharacterBody3D

@export var speed: float = 5.0
@export var speed_multiplyer: float = 2.0
const JUMP_VELOCITY: float = 4.5
var remaining_jumps: int = 2

@onready var camera: Node3D = $CameraRig/Camera3D

@export var wall_run_speed: float = 9.0
@export var wall_run_acceleration: float = 6.0
@export var wall_run_duration: float = 3.0
@export var wall_run_gravity: float = 1.5
@export var wall_run_up_boost: float = 3.0
@export var wall_stick_force: float = 8.0
@export var wall_check_distance: float = 1.2

var wall_run_timer: float = 0.0
var is_wall_running: bool = false
var wall_normal: Vector3 = Vector3.ZERO
var wall_run_direction: Vector3 = Vector3.ZERO
var can_wall_run: bool = true
var last_wall_normal: Vector3 = Vector3.ZERO

@export var wall_jump_horizontal_force: float = 8.0
@export var wall_jump_upward: float = 6.0

@export var dash_speed: float = 25.0
@export var dash_time: float = 0.35
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var can_dash: bool = true


func _physics_process(delta: float) -> void:
	var grounded: bool = is_on_floor()

	# reset everything on landing
	if grounded:
		can_dash = true
		can_wall_run = true
		wall_run_timer = 0.0
		remaining_jumps = 1
		is_wall_running = false
		last_wall_normal = Vector3.ZERO

	# gravity
	if not grounded and not is_wall_running and not is_dashing:
		velocity += get_gravity() * delta
	elif is_wall_running:
		velocity.y = move_toward(velocity.y, -wall_run_gravity, wall_run_gravity * delta)

	var input_dir: Vector3 = get_input_direction()

	# dash initiate
	if Input.is_action_just_pressed("dash") and not is_dashing and can_dash:
		is_dashing = true
		dash_timer = dash_time
		var cam_forward := -camera.global_transform.basis.z
		cam_forward.y = 0.0
		dash_direction = input_dir if input_dir != Vector3.ZERO else cam_forward.normalized()
		can_dash = false

	# normal movement
	var current_speed: float = speed
	if Input.is_action_pressed("Sprint"):
		current_speed *= speed_multiplyer

	if not is_dashing and not is_wall_running:
		if input_dir != Vector3.ZERO:
			velocity.x = input_dir.x * current_speed
			velocity.z = input_dir.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_speed)
			velocity.z = move_toward(velocity.z, 0.0, current_speed)

	# dash movement
	if is_dashing:
		var cam_dir: Vector3 = -camera.global_transform.basis.z
		cam_dir.y = 0.0
		cam_dir = cam_dir.normalized()
		dash_direction = dash_direction.lerp(cam_dir, 0.15).normalized()
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		velocity.y = 0.0
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

	var wall_hit: Dictionary = check_wall()
	var wall_detected: bool = not wall_hit.is_empty()

	# end wall run if wall is gone or timer expired
	if is_wall_running and (not wall_detected or wall_run_timer <= 0.0):
		is_wall_running = false
		velocity.x = 0.0
		velocity.z = 0.0

	# jump input handles normal jump, wall run start, and wall jump
	if Input.is_action_just_pressed("ui_accept"):
		if is_wall_running:
			velocity.x = wall_normal.x * wall_jump_horizontal_force
			velocity.z = wall_normal.z * wall_jump_horizontal_force
			velocity.y = wall_jump_upward
			is_wall_running = false
			last_wall_normal = wall_normal
			can_wall_run = false
		elif not grounded:
			if wall_detected and can_wall_run and wall_hit["normal"] != last_wall_normal:
				_start_wall_run(wall_hit)
			elif remaining_jumps > 0:
				remaining_jumps -= 1
				velocity.y = JUMP_VELOCITY
		else:
			velocity.y = JUMP_VELOCITY



	# wall run movement
	if is_wall_running and wall_run_timer > 0.0:
		wall_run_timer -= delta

		# keep wall normal and direction up to date
		if wall_detected:
			wall_normal = wall_hit["normal"]
			var new_dir: Vector3 = wall_normal.cross(Vector3.UP).normalized()
			if new_dir.dot(wall_run_direction) < 0:
				new_dir = -new_dir
			wall_run_direction = new_dir

		if input_dir != Vector3.ZERO:
			var target_vel: Vector3 = wall_run_direction * wall_run_speed
			velocity.x = move_toward(velocity.x, target_vel.x, wall_run_acceleration)
			velocity.z = move_toward(velocity.z, target_vel.z, wall_run_acceleration)
		else:
			# bleed off speed slowly when no input
			velocity.x = move_toward(velocity.x, 0.0, 1.5)
			velocity.z = move_toward(velocity.z, 0.0, 1.5)

		# pull into wall so we don't drift off
		velocity -= wall_normal * wall_stick_force * delta

		remaining_jumps = 1
		can_wall_run = false

	move_and_slide()
	turn_to(input_dir)


func _start_wall_run(wall_hit: Dictionary) -> void:
	is_wall_running = true
	wall_run_timer = wall_run_duration
	wall_normal = wall_hit["normal"]

	# figure out which way along the wall to run
	wall_run_direction = wall_normal.cross(Vector3.UP).normalized()
	var player_forward := -transform.basis.z
	if wall_run_direction.dot(player_forward) < 0:
		wall_run_direction = -wall_run_direction

	# small upward boost on attach
	velocity.y = wall_run_up_boost


func turn_to(direction: Vector3) -> void:
	if direction != Vector3.ZERO:
		var yaw: float = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, yaw, 0.1)


func check_wall() -> Dictionary:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = global_transform.origin

	var query_right := PhysicsRayQueryParameters3D.create(origin, origin + transform.basis.x * wall_check_distance)
	query_right.exclude = [self]
	var result_right: Dictionary = space_state.intersect_ray(query_right)
	if not result_right.is_empty():
		return result_right

	var query_left := PhysicsRayQueryParameters3D.create(origin, origin + -transform.basis.x * wall_check_distance)
	query_left.exclude = [self]
	var result_left: Dictionary = space_state.intersect_ray(query_left)
	if not result_left.is_empty():
		return result_left

	return {}


func get_input_direction() -> Vector3:
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var dir: Vector3 = (camera.global_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	return Vector3(dir.x, 0.0, dir.z).normalized() * input_dir.length()
