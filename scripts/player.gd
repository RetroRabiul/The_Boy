extends CharacterBody3D



var bob_freq: float = 3.0
var bob_amp: float = 0.08
var t_bob: float = 0.0


#var lean_amount: float = 10.0
#var lean_weight: float = 1.0

var lean_amount: float = 0.75
var lean_weight: float = 0.05

@export var world: Node3D

@onready var head = $Camera
@onready var use_ray = %UseRayCast
@onready var joint = %InspectJoint
@onready var hud = %HUD
var look_rotation: Vector3 = Vector3.ZERO
const SPEED = 5.0
const JUMP_VELOCITY = 30.5
var sensitivity = 0.2



var throw_force = 3.0
var follow_speed = 20.0
var held_item = null

var show_mouse: bool = true

var on_ladder: bool = false

var gravity_vec:Vector3 = Vector3.ZERO

var jump = 5

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	show_mouse = false




func _wobble(input_dir: Vector2, delta):
	if input_dir.x>0:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-lean_amount), lean_weight)
	elif input_dir.x<0:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(lean_amount), lean_weight)
	else:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(0), lean_weight)
	t_bob += delta * velocity.length() * float(is_on_floor())
	$Camera/Camera3D.transform.origin =_headbob(t_bob)



func _headbob(time)->Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq/ 10) * bob_amp
	return pos


func _physics_process(delta: float) -> void:
	
	if show_mouse: return
	
	head.rotation_degrees.x = look_rotation.x
	rotation_degrees.y = look_rotation.y
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: Vector3
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	

	var gravity =  get_gravity()
	
	var head_dir: float = abs(head.rotation_degrees.x)
	
	if on_ladder and head_dir > 20.0:
		
		var ladder_dir = -1
		if head.rotation_degrees.x < 0.0:
			ladder_dir = 1
		direction = Vector3(h_input,f_input*ladder_dir,0).rotated(Vector3.UP, h_rot).normalized()

	else:

	#jumping and gravity
		if is_on_floor():
			gravity_vec = Vector3.ZERO
		else:
			if not on_ladder:
				gravity_vec -= Vector3.DOWN * gravity * delta
		

		#Jump
		if Input.is_action_just_pressed("ui_accept"):
				gravity_vec = Vector3.UP * jump
		
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()

	
	velocity = direction  * SPEED
	var movement = Vector3.ZERO
	movement = velocity + gravity_vec
	velocity = movement

	move_and_slide()
	_check_ray()
	_handle_item()



	
func _input(event):

	if Input.is_action_just_pressed("menu"):
		if show_mouse:
			show_mouse = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			show_mouse = true
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
	if show_mouse: return
			
	if event is InputEventMouseMotion:
		look_rotation.y -= sensitivity * event.relative.x
		look_rotation.x -= sensitivity * event.relative.y
		look_rotation.x = clamp(look_rotation.x, -80, 50)

	if Input.is_action_just_pressed("pick"):
		if use_ray.is_colliding():
			if use_ray.get_collider().is_in_group("pick_up"):
				#print(use_ray.get_collider().name)
				_pick_up_item(use_ray.get_collider())
				
	if Input.is_action_just_pressed("drop"):
		_throw_held_object()
	
	if Input.is_action_just_pressed("keep"):
		_keep_item()
#
func _keep_item():
	if held_item == null: return
#		NOT HOLDING anything
		
	if not held_item.in_inventory: return
#		item cannot be put in inventory
		
	_remove_held()

func _remove_held():
	held_item.queue_free()
	held_item = null
	joint.set_node_b(joint.get_path())


func _pick_up_item(item):
	if held_item != null: return
	held_item = item
	held_item.was_picked()
	_add_item_to_inventory()
	_item_to_hold_position()

func _item_to_hold_position():
	joint.set_node_b(held_item.get_path())
	var grab_tween = create_tween()
	grab_tween.tween_property(held_item, "global_position", joint.global_position, 0.5)

func _add_item_to_inventory():
	if hud.inventory_has_room():
		if held_item.inventory_texture != null:
			held_item.keep_me()


func _throw_held_object():
	if held_item == null: return
	var obj:RigidBody3D = held_item
	GlobalSignals.drop_item.emit(held_item.item_name)
#	Remove item from HUD inventory
	held_item = null
	joint.set_node_b(joint.get_path())
	obj.apply_central_impulse(-head.global_basis.z * throw_force * 2.0)
	obj.set_collision_layer_value(2, true)
	obj.in_inventory = false
	
	

func item_from_inventory(item_name:String):
	if held_item != null:
		if held_item.in_inventory:
#			Swap held item for new item from inventory
			_remove_held()
		else: return
#			holding item that cannot be put in inventory
	
	var item_scene_main = load(world.inventory_items[item_name])	
	var item_scene = item_scene_main.instantiate()
	world.add_child(item_scene)
	item_scene.global_position = joint.global_position
	held_item = item_scene
	held_item.from_inventory()
	_item_to_hold_position()
	

	
func _handle_item():
	if held_item != null:
		var targetPos = joint.global_transform.origin
		var objectPos = held_item.global_transform.origin
		held_item.linear_velocity = (targetPos - objectPos) * follow_speed
	

func _check_ray():
	if use_ray.is_colliding():
		if use_ray.get_collider().is_in_group("highlight"):
			hud.target_state(true)
		else:
			hud.target_state(false)
	else:
		hud.target_state(false)
