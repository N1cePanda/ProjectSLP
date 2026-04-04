extends SpringArm3D

@onready var camera: Camera3D = $Camera3D
@export var turn_rate := 200
@export var mouse_sens := .10
@export var normal_fov := 80.0
@export var sprint_fov := 100.0
@export var dash_fov := 120.0
@export var fov_lerp_speed := 8.0

@onready var player: CharacterBody3D = get_parent()

var camera_rig_height: float = position.y
var mouse_input: Vector2 = Vector2()

func _ready() -> void:
	spring_length = camera.position.z
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	var look_input := Input.get_vector("view_left", "view_right", "view_up", "view_down")
	look_input = turn_rate * look_input * delta
	look_input += mouse_input
	mouse_input = Vector2()
	rotation_degrees.y -= look_input.x
	rotation_degrees.x -= look_input.y
	rotation_degrees.x = clampf(rotation_degrees.x, -45, 60)

	# dash fov takes priority over sprint fov
	var target_fov := normal_fov
	if player.is_dashing:
		target_fov = dash_fov
	elif Input.is_action_pressed("Sprint"):
		target_fov = sprint_fov

	camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = event.relative * mouse_sens
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	position = player.position + Vector3(0, camera_rig_height, 0)
