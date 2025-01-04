extends CharacterBody3D

@onready var camera = $Head/Camera
@onready var character_mover = $charactermover

@export var mouse_sensitivity_h = .13
@export var mouse_sensitivity_v = .13

@onready var interact_ray = $Head/Camera/InteractRay
@onready var hand_marker = $HandMarker
@onready var sword_manager = $Head/Camera/weaponManager/swordManager
@onready var label1 = $"Head/Camera/UI 2"
var maxDrawReached = false
var object_in_hand = false
var picked_up_object = null

var dead = false

var previous_action = ""

var m2_drawTime = 0.0
var m2_maxDraw = 1.0 
var is_m2_held = false

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
		previous_action = "Heavy Slash"
		if m2_drawTime >= m2_maxDraw:
			sword_manager.swordSpin()
		
		
	if Input.is_action_pressed("draw sword"):
		if !is_m2_held:
			is_m2_held = true
			m2_drawTime = 0.0
		m2_drawTime += delta
		
		sword_manager.drawSword()
		
		if m2_drawTime >= m2_maxDraw && !maxDrawReached:
			print("Max Draw")
			sword_manager.maxDraw()
			maxDrawReached = true
	elif Input.is_action_just_released("draw sword"):
		
		if m2_drawTime < m2_maxDraw:
			sword_manager.stopDrawSword()  
		else:
			sword_manager.swordSpin()
		is_m2_held = false
		maxDrawReached = false
