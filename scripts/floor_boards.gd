extends CSGBox3D

func _ready() -> void:
	GlobalSignals.tin_pick.connect(_tin_pick)

func _tin_pick():
	use_collision = false
	visible = false
	$FloorboardsCrack.play()
	


func _on_floorboards_crack_finished() -> void:
	queue_free()
