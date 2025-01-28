extends Control


@onready var target = %TextureRect
@export var player:CharacterBody3D

var inventory_item_scene = preload("res://scence/ui/inventory_item.tscn")

var max_inventory: int = 4

func _ready() -> void:
	GlobalSignals.keep_item.connect(_add_inventory)
	GlobalSignals.drop_item.connect(_drop_item)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("slot_1"):
		_get_from_inventory(0)
	if Input.is_action_just_pressed("slot_2"):
		_get_from_inventory(1)
	if Input.is_action_just_pressed("slot_3"):
		_get_from_inventory(2)
	if Input.is_action_just_pressed("slot_4"):
		_get_from_inventory(3)
	if Input.is_action_just_pressed("slot_5"):
		_get_from_inventory(4)
	if Input.is_action_just_pressed("slot_6"):
		_get_from_inventory(5)
	if Input.is_action_just_pressed("slot_7"):
		_get_from_inventory(6)
	if Input.is_action_just_pressed("slot_8"):
		_get_from_inventory(7)
	if Input.is_action_just_pressed("slot_9"):
		_get_from_inventory(8)
		
func _get_from_inventory(slot: int):
	if slot > %Inventory.get_child_count()-1: return
	var item_name = %Inventory.get_child(slot).item_name
	player.item_from_inventory(item_name)		
		
func target_state(state):
	if state:
		target.modulate.a = 1.0
	else:
		target.modulate.a = 5.0

func inventory_has_room()->bool:
	var inventory_count: int =  %Inventory.get_child_count()
	if inventory_count < max_inventory: 
		return true
	else:
		return false

func _add_inventory(item_name: String, item_texture: Texture2D):
	var inventory_item = inventory_item_scene.instantiate()
	inventory_item.set_item(item_name, item_texture)
	%Inventory.add_child(inventory_item)
	set_inventory_index()
	
func _drop_item(item_name:String):
	for item in %Inventory.get_children():
		await get_tree().process_frame
#		need to wait for frame to finish otherwise delte not updating
		if item.item_name == item_name:
			item.queue_free()
	
	set_inventory_index()
	
func set_inventory_index():
	var inventory_count = %Inventory.get_child_count()
	for i in inventory_count:
		%Inventory.get_child(i).set_index(i+1)
