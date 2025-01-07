extends CharacterBody3D

@onready var camera = $Head/Camera
@onready var character_mover = $charactermover

@export var mouse_sensitivity_h = .13
@export var mouse_sensitivity_v = .13


@onready var hand_marker = $HandMarker
@onready var sword_manager = $Head/Camera/weaponManager/swordManager
@onready var label1 = $"Head/Camera/UI 2"
var maxDrawReached = false
var object_in_hand = false
var picked_up_object = null

var dead = false

var previous_action = ""

var m2_drawTime = 0.0
var m2_maxDraw = 0.35
var is_m2_held = false
var canUpperCut = true
@onready var upper_cut_timer = $upperCutTimer

#hooking System
@export var hook_reach = 30.0
var can_hook = true
@onready var hooking_timer = $hookingTimer
@onready var hook_target = null
var is_hooked = false
@onready var hook_cast = $Head/Camera/hookCast



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	label1.text = "Action Pressed: "
	
func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
		camera.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -78, 90)

func _physics_process(delta):
	if dead:
		return

	if previous_action != "":
		label1.text = "Action Pressed: " + previous_action

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		previous_action = "Quit"
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		previous_action = "Restart"
	if Input.is_action_just_pressed("fullscreen"):
		var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if fs:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		previous_action = "Toggle Fullscreen"
	if Input.is_action_just_pressed("dash"):
		character_mover.dash()
		previous_action = "Dash"
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	character_mover.set_move_dir(move_dir)

	if Input.is_action_just_pressed("jump"):
		character_mover.jump()
		previous_action = "Jump"
		
	if Input.is_action_just_pressed("hit"):
		sword_manager.slash()
		##sword_manager.spawn_projectile()
		previous_action = "Heavy Slash"

	if Input.is_action_pressed("draw sword"):
		if !is_m2_held:
			is_m2_held = true
			m2_drawTime = 0.0
			sword_manager.play_drawspin() 
		m2_drawTime += delta
		if m2_drawTime >= m2_maxDraw and !maxDrawReached:
			maxDrawReached = true
			sword_manager.play_maxdraw()  # Play looping max draw animation
	elif Input.is_action_just_released("draw sword"):
		if maxDrawReached:
			sword_manager.play_spinrelease()  # Play spin release animation
		else:
			sword_manager.reverse_drawspin()  # Reverse drawspin to idle
		reset_draw_state()

	if Input.is_action_just_pressed("uppercut") && canUpperCut:
		canUpperCut = false
		character_mover.uppercut()
		sword_manager.uppercut()
		upper_cut_timer.start()
		
	#hooking logic starts here
	
	if Input.is_action_just_pressed("hook") && can_hook:
		if hook_cast.is_colliding():
			print("Collider hit: ")
			var collider = hook_cast.get_collider()  # Get the collider the ray hit
			if collider and collider.has_method("on_hooked"):  # Check if the collider is hookable
				print("HOOOKEDDD")
				collider.on_hooked()  # Trigger the hookable object's response
				character_mover.start_hook(hook_cast.get_collision_point())
				can_hook = false
				hooking_timer.start()
			
	if is_hooked:
		character_mover.move_to_hook()
	if Input.is_action_just_pressed("slam"):
		character_mover.slam()
		sword_manager.slamDown()



func reset_draw_state():
	is_m2_held = false
	maxDrawReached = false


func _on_sword_manager_spin_released():
	character_mover.launch_forward()


func _on_upper_cut_timer_timeout():
	canUpperCut = true
	print("I can uppercut again")


func _on_hooking_timer_timeout():
	can_hook = true


