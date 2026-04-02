extends SpringArm3D

@onready var camera  : Camera3D = $Camera3D
@export var turn_rate := 200 
@export var mouse_sens := .10 
@export var normal_fov := 75.0
@export var sprint_fov := 90.0
@export var fov_lerp_speed := 8.0
@onready var player: CharacterBody3D = get_parent() #onready basically says for the script to start when seen, as _ready is the starter call for the tree to be read
var camera_rig_height: float = position.y
var mouse_input: Vector2 = Vector2() #stating that mouseinput, which is a vector, is a vector. Variables seems like they should be stated in start of script
func _ready() -> void: 
	spring_length = camera.position.z
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	var look_input:= Input.get_vector("view_left", "view_right", "view_up", "view_down") #define process/variables
	look_input = turn_rate * look_input * delta #add in settings/ call support 
	look_input += mouse_input #syncing up the var mouse_input to the game look_input 
	mouse_input = Vector2()
	rotation_degrees.y += look_input.x #end with output result 
	rotation_degrees.x += look_input.y  
	rotation_degrees.x = clampf(rotation_degrees.x, -45, 60)
	var target_fov: = normal_fov
	if Input.is_action_pressed("Sprint"):
		target_fov = sprint_fov

	camera.fov = lerp(camera.fov, target_fov, fov_lerp_speed * delta)




func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion: #honing event type to what we want to do
		mouse_input = event.relative * mouse_sens
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

func _physics_process(delta: float) -> void:
	position = player.position + Vector3(0, camera_rig_height, 0) #Top Level is very important for not adding extra transform input to your stationary nodes
	
	
