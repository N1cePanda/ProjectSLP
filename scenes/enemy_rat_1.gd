extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@export var speed: float = 3.5
@export var gravity: float = 9.8

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
		if not nav.is_navigation_finished():
			var next_location: Vector3 = nav.get_next_path_position()
			var direction: Vector3 = (next_location - global_transform.origin).normalized()
			var new_velocity: Vector3 = direction * speed
			velocity = velocity.move_toward(new_velocity, speed * delta)

	move_and_slide()

func target_position(target: Vector3) -> void:
	nav.target_position = target
