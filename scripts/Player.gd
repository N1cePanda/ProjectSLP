extends CharacterBody3D

@export var speed := 5.0
const JUMP_VELOCITY = 4.5
var remaining_jumps := 2
@export var speed_multiplyer := 2.0
@onready var camera: Node3D = $CameraRig/Camera3D
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta 
	else:
		remaining_jumps = 2

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)) 
	direction = Vector3(direction.x, 0, direction.z).normalized() * input_dir.length()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_pressed("Sprint"):
		velocity.x  *= speed_multiplyer
		velocity.z  *= speed_multiplyer

	if Input.is_action_just_pressed("ui_accept") and remaining_jumps > 0:
		remaining_jumps -= 1 
		velocity.y = JUMP_VELOCITY
	move_and_slide()
	turn_to(direction) #calling for direction from highup function to be used in lower down function VERY IMPORTANT EG. func_calling_func(func_being_called) IN the func being called
func turn_to (direction: Vector3)-> void: 
	if direction:
		var yaw:= atan2(-direction.x, -direction.z) 
		yaw = lerp_angle(rotation.y, yaw, .1)
		rotation.y = yaw 
		#print(self.transform)
