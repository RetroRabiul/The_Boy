extends SpotLight3D



func _process(delta):
	if Input.is_action_just_pressed("flashlight"):
		visible = !visible
		$flashlight_sound.play()
