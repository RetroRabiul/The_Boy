extends Control


@onready var target = %TextureRect



func target_state(state):
	if state:
		target.modulate.a = 1.0
	else:
		target.modulate.a = 5.0
