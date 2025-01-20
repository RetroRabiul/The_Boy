extends Area3D

var is_active: bool = false

func _ready() -> void:
	GlobalSignals.tin_pick.connect(_ladder_active)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and is_active:
		print ("ON LADDER")
		body.on_ladder = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and is_active:
		print ("OFF LADDER")
		body.velocity.y = 0.0
		body.on_ladder = false

func _ladder_active():
	get_tree().create_timer(2.0).timeout
	is_active = true
