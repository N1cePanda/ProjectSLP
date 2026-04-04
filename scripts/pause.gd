extends Control

func resume()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false 
	$"../../AnimationPlayer".play_backwards("pause_menu")
	hide()
func pause()->void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$"../../AnimationPlayer".play("pause_menu")
	show()
func test_pause()->void:
	if Input.is_action_just_pressed("ui_pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("ui_pause") and get_tree().paused == true:
		resume()
	

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	test_pause()
