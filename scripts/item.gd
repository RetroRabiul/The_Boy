extends RigidBody3D

@export var max_speed: float = 5.0
@export var pick_signal: String
@export var item_name: String
@export var inventory_texture: Texture2D

var in_inventory: bool = false

func was_picked():
	set_collision_layer_value(2, false)
	if pick_signal != "":
		GlobalSignals.emit_signal(pick_signal)

func from_inventory():
	in_inventory = true
	set_collision_layer_value(2, false)	


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var len = min(max_speed, state.linear_velocity.length())
	state.linear_velocity = state.linear_velocity.normalized() * len
	

func keep_me():
	GlobalSignals.keep_item.emit(item_name, inventory_texture)
	in_inventory = true
	
