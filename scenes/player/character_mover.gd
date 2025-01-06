extends Node3D

@export var jump_force = 9.0
@export var gravity = 21.0

@export var max_speed = 6.0
@export var move_accel = 4.0
@export var stop_drag = 0.4

var character_body : CharacterBody3D
var move_drag = 0.0
var move_dir: Vector3
var isLaunching = true
var launch_force = 1000.0

var uppercut_force = 25

var isDashing: bool = false
var dashMeter: float = 3.0
var dashForce: float = 8.1
var dashTime: float = 0.0
var dashDuration: float = 0.2  
var dashCooldownTime: float = 2.0
@onready var label = $"../Head/Camera/Label"
@onready var audio_manager = $"../audio_manager"

# Called when the node enters the scene tree for the first time
func _ready():
	character_body = get_parent()  # Get the CharacterBody3D (the parent node)
	move_drag = float(move_accel) / max_speed

# Set the movement direction for the character
func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir
	
func launch_forward():
	if !isLaunching:
		isLaunching = true
		var forward_dir = -character_body.transform.basis.z.normalized()
		character_body.velocity += forward_dir * launch_force
		audio_manager.dash() 
		print("spin!!!")
# Simplified jump function
func jump():
	if character_body.is_on_floor():
		character_body.velocity.y = jump_force  # Apply the jump force only when on the floor
func uppercut():
	character_body.velocity.y = uppercut_force

# Dash functionality
func dash():
	if dashMeter >= 1.0 && !isDashing:
		dashMeter += -1.0
		isDashing = true
		dashTime = dashDuration
		audio_manager.dash()

# Called every frame, handling physics updates
func _physics_process(delta):
	if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
		character_body.velocity.y = 0.0  # Prevent clipping into the ceiling

	# Apply gravity only when not on the floor
	if not character_body.is_on_floor():
		character_body.velocity.y -= gravity * delta

	# Handle dash meter refill
	if dashMeter < 3.0:
		dashMeter += delta / dashCooldownTime
		dashMeter = clamp(dashMeter, 0.0, 3.0)

	var drag = move_drag
	if move_dir.is_zero_approx():
		drag = stop_drag

	# Handle dashing behavior
	if isDashing:
		character_body.velocity += move_dir * dashForce
		dashTime -= delta
		if dashTime <= 0.0:
			isDashing = false
			dashTime = 0.0
	elif isLaunching:
		# Allow drag to slow the launch over time
		isLaunching = false  # Reset launch after applying force
	elif character_body.is_on_floor():
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0  # Keep Y velocity unaffected by movement
		character_body.velocity += move_accel * move_dir - flat_velo * drag
	else:
		# Apply movement logic when not dashing
		var flat_velo = character_body.velocity
		flat_velo.y = 0.0  # Keep vertical velocity unaffected by horizontal movement
		character_body.velocity += move_accel * move_dir - flat_velo * drag

	# Apply the movement with sliding, and let the character move with friction applied
	character_body.move_and_slide()

	# Update the label to show relevant information
	label.text = "Speed: %.2f\n" % character_body.velocity.length() + "\nIs Dashing: " + str(isDashing) + "\nDash Meter: %.2f" % dashMeter + "\nDash Time: %.2f" % dashTime + "\nDash Duration: %.2f" % dashDuration + "\nMove Dir: " + str(move_dir)
