extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@export var speed: float = 3.5
@export var gravity: float = 9.8

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

		# Move along path if available
		if not nav.is_navigation_finished():
			var next_location: Vector3 = nav.get_next_path_position()
			var direction: Vector3 = (next_location - global_transform.origin).normalized()
			
			# Horizontal movement
			var horizontal_velocity: Vector3 = direction * speed
			horizontal_velocity.y = velocity.y  # preserve gravity
			velocity = horizontal_velocity

			# Smooth and fast rotation toward movement direction
			if direction.length() > 0.01:
				var target_yaw: float = atan2(direction.x, direction.z)
				rotation.y = lerp_angle(rotation.y, target_yaw, 15 * delta)

	# Move the character
	move_and_slide()

func target_position(target: Vector3) -> void:
	nav.target_position = target
