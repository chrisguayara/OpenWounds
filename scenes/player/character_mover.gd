extends Node3D

@export var jump_force = 9.0
@export var gravity = 21.0

@export var max_speed = 6.0
@export var move_accel = 4.0
@export var stop_drag = 0.4

var character_body : CharacterBody3D
var move_drag = 0.0
var move_dir: Vector3

var isDashing: bool = false
var dashMeter: float = 3.0
var dashForce: float = 8.1
var dashTime: float = 0.0
var dashDuration: float = 0.2  
var dashCooldownTime: float = 2.0
@onready var label = $"../Head/Camera/Label"
@onready var audio_manager = $"../audio_manager"



func _ready():
	character_body = get_parent()
	move_drag = float(move_accel) / max_speed

func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir 

func jump():
	if character_body.is_on_floor():
		character_body.velocity.y = jump_force

func dash():
	if dashMeter >= 1.0 && !isDashing:
		dashMeter += -1.0
		isDashing = true
		dashTime = dashDuration
		audio_manager.dash()

func _physics_process(delta):
	if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
		character_body.velocity.y = 0.0
	if not character_body.is_on_floor():
		character_body.velocity.y -= gravity * delta
	
	if dashMeter < 3.0:
		dashMeter += delta / dashCooldownTime  # Increment dashMeter over time
		dashMeter = clamp(dashMeter, 0.0, 3.0)

	var drag = move_drag
	if move_dir.is_zero_approx():
		drag = stop_drag
	
	if isDashing:
		character_body.velocity += move_dir * dashForce
		dashTime -= delta
		
		if dashTime <= 0.0:
			isDashing = false
			dashTime = 0.0
	else: 
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0
		character_body.velocity += move_accel * move_dir - flat_velo * drag
	
	character_body.move_and_slide()
	
	label.text = "Speed: %.2f\n" % character_body.velocity.length() + "\nIs Dashing: " + str(isDashing) + "\nDash Meter: %.2f" % dashMeter + "\nDash Time: %.2f" % dashTime + "\nDash Duration: %.2f" % dashDuration + "\nMove Dir: " + str(move_dir)


