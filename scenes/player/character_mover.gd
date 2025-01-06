extends Node3D

@export var jump_force = 9.0
@export var gravity = 21.0

@export var max_speed = 15.0
@export var move_accel = 4.0
@export var stop_drag = 0.4

var character_body : CharacterBody3D
var move_drag = 0.0
var move_dir: Vector3
var isLaunching = true
var launch_force = 750.0

var uppercut_force = 25
var uppercut_momentum = Vector3.ZERO
var dash_momentum = Vector3.ZERO 
var launch_momentum = Vector3.ZERO

var isDashing: bool = false
var dashMeter: float = 2.0
var dashForce: float = 4.1
var dashTime: float = 0.0
var dashDuration: float = 0.2  
var dashCooldownTime: float = 2.0
@onready var label = $"../Head/Camera/Label"
@onready var audio_manager = $"../audio_manager"

var current_speed: float = 0.0

var isHooking = false
var hook_target : Vector3
var hook_speed = 100
var hook_momentum = 0.0



func _ready():
	character_body = get_parent() 
	move_drag = float(move_accel) / max_speed


func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir
	
func launch_forward():
	if !isLaunching:
		isLaunching = true
		var forward_dir = -character_body.transform.basis.z.normalized()
		character_body.velocity += forward_dir * launch_force
		launch_momentum = forward_dir * launch_force 
		audio_manager.launch() 
		print("spin!!!")
		dashMeter = 2.0
var hasThrusted = false
func thrust():
	if !hasThrusted:
		hasThrusted = true
		var forward_dir = -character_body.transform.basis.z.normalized()
		character_body.velocity += forward_dir * launch_force
		launch_momentum = forward_dir * launch_force 
		audio_manager.launch() 
		print("thrust!!!")

func jump():
	if character_body.is_on_floor():
		character_body.velocity.y = jump_force 
func uppercut():
	character_body.velocity.y = uppercut_force
	uppercut_momentum = Vector3(0, uppercut_force, 0)


func dash():
	if dashMeter >= 1.0 && !isDashing:
		dashMeter += -1.0
		isDashing = true
		dashTime = dashDuration
		dash_momentum = move_dir * dashForce 
		audio_manager.dash()


func _physics_process(delta):
	if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
		character_body.velocity.y = 0.0  

	if not character_body.is_on_floor():
		character_body.velocity.y -= gravity * delta


	if dashMeter < 2.0:
		dashMeter += delta / dashCooldownTime
		dashMeter = clamp(dashMeter, 0.0, 2.0)

	var drag = move_drag
	if move_dir.is_zero_approx():
		drag = stop_drag


	if isDashing:
		character_body.velocity += move_dir * dashForce
		dashTime -= delta
		if dashTime <= 0.0:
			isDashing = false
			dashTime = 0.0
	elif isLaunching:

		isLaunching = false 
	elif character_body.is_on_floor():
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0 
		character_body.velocity += move_accel * move_dir - flat_velo * drag
	else:
	
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0  
		character_body.velocity += move_accel * move_dir - flat_velo * drag
		
		launch_momentum = Vector3.ZERO
		dash_momentum = Vector3.ZERO
		uppercut_momentum = Vector3.ZERO
	character_body.move_and_slide()
	
	#hookLogic
	if isHooking:
		move_to_hook(delta)
	
	label.text = "Speed: %.2f\n" % character_body.velocity.length() + "\nIs Dashing: " + str(isDashing) + "\nDash Meter: %.2f" % dashMeter + "\nDash Time: %.2f" % dashTime + "\nDash Duration: %.2f" % dashDuration + "\nMove Dir: " + str(move_dir)

func start_hook(target: Vector3):
	hook_target = target
	isHooking = true
	

func move_to_hook(delta):
	var direction = (hook_target - character_body.global_position).normalized()
	var distance = (hook_target - character_body.global_position).length()

	# Apply a force towards the hook target
	if distance > 1.0:  # Stop if close enough
		character_body.velocity = direction * hook_speed
		if !hasThrusted:
			thrust() 
	else:
		character_body.velocity = direction * max_speed
		character_body.apply_floor_snap()
		isHooking = false
		hasThrusted = false
