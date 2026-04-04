extends Node

@onready var target: Node3D = $PlayerCharacter  # your player node

func _process(delta: float) -> void:
	get_tree().call_group("enemies", "target_position", target.global_transform.origin)
