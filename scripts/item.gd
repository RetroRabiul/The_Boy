extends RigidBody3D


@export var max_speed: float = 5.0

@export var pick_signal: String

func was_picked():
	print ("picked")
	if pick_signal != "":
		GlobalSignals.emit_signal(pick_signal)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var len = min(max_speed, state.linear_velocity.length())
	state.linear_velocity = state.linear_velocity.normalized() * len
	
