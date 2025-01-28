extends Node3D

#var mug_scene:PackedScene = preload("res://scripts/mug.tscn")
#var tin_scene:PackedScene = preload("res://scripts/tin.tscn")
#var box_scene:PackedScene = preload("res://scripts/box.tscn")


#var inventory_items: Dictionary = {
	#"mug": mug_scene,
	#"tin": tin_scene,
	#"box": box_scene
#}

var inventory_items: Dictionary = {
	"mug": "res://scripts/mug.tscn",
	"tin": "res://scripts/tin.tscn",
	"box": "res://scripts/box.tscn"
}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
