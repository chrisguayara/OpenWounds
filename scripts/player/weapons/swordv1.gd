extends Node3D

var AreaDamage: int = 34
@onready var audio_manager = $"../../../../audio_manager"

@onready var swordAnim = $"../../handManager/handsv1/AnimationPlayer"
@onready var handsv_1 = $"../../handManager/handsv1"
@onready var swordCollider = $"../../handManager/handsv1/armsrig/Skeleton3D/arm/Area3D/collider"


var current_animation = "idle"
var canSwing = true
var canChain = false
var inputQueued = false
@onready var label = $"../../UI 2"

var animation_speed = 1.0  # Default speed (1.0 is normal speed)\
signal spinReleased


func _ready():
	set_animation_speed(1.5)
	swordCollider.disabled =true


# Function to adjust animation speed
func set_animation_speed(speed: float):
	animation_speed = speed
	swordAnim.speed_scale = animation_speed  # Set speed scale for AnimationPlayer

func slash():
	if !canSwing:
		# Queue input if animation is still running
		inputQueued = true
	
	if canSwing:
		if current_animation == "idle":
			current_animation = "heavySwingRight"
			swordAnim.play("heavySwingRight")
			audio_manager.slash()
			canSwing = false
			canChain = true
		elif canChain and inputQueued:
			if current_animation == "heavySwingRight":
				current_animation = "swingLeft"
				swordAnim.play("swingLeft")
				audio_manager.slash()
			elif current_animation == "swingLeft":
				current_animation = "transition"
				swordAnim.play("transition")
			elif current_animation == "transition":
				current_animation = "heavySwingRight"
				swordAnim.play("heavySwingRight")
				audio_manager.slash()

func play_drawspin():
	current_animation = "drawSpin"
	swordAnim.play("drawSpin",-1,0.4, false)


# Play the max draw looping animation
func play_maxdraw():
	current_animation = "maxDraw"
	swordAnim.play("maxDraw")
	audio_manager.maxDrawReached()


func reverse_drawspin():
	current_animation = "idle"
	swordAnim.play_backwards("drawSpin")



func play_spinrelease():
	current_animation = "spinRelease"
	swordAnim.play("spinRelease",-1,1.0,false)
	emit_signal("spinReleased")
	
func reset_sword_state():
	current_animation = "idle"
	swordAnim.play("idle")
	canSwing = true
	canChain = false
	inputQueued = false

func uppercut():
	current_animation = "spinRelease"
	swordAnim.play("spinRelease")
	audio_manager.uppercut()

func slamDown():
	current_animation = "transitionSlam"
	swordAnim.play("transitionSlam",-1,2,false)
	audio_manager.uppercut()
	swordCollider.disabled = false
	


func _physics_process(delta):
	label.text = "current_animation: " + str(current_animation) + "\nInputQueued: " + str(inputQueued) + "\ncanChain: " + str(canChain)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "transitionSlam":
		current_animation = "slamSpin"
		swordAnim.play("slamSpin")
	if anim_name == "spinRelease":
		reset_sword_state()
		swordAnim.play("idle")
	if anim_name == "heavySwingRight" or anim_name == "swingLeft" or anim_name == "transition":
		canSwing = true 
		
		if anim_name == "heavySwingRight":
			if !inputQueued:
				print("input cancelled")
				current_animation = "idle"
				swordAnim.play_backwards("heavySwingRightRev")
				canSwing = true
				canChain = false
				inputQueued = false
			else:
				current_animation = "swingLeft"
				swordAnim.play("swingLeft")
				audio_manager.slash()
				canSwing = false
				canChain = true

		elif anim_name == "swingLeft":
			current_animation = "transition"
			swordAnim.play("transition")
			canSwing = false 

		elif anim_name == "transition":
			if inputQueued:
				current_animation = "heavySwingRight"
				swordAnim.play("heavySwingRight")
				audio_manager.slash()
				canSwing = false
				canChain = true
				inputQueued = false  
			else:
				reset_sword_state()



