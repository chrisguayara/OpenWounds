extends Node3D

var AreaDamage: int = 34
@onready var audio_manager = $"../../../../audio_manager"

@onready var swordAnim = $"../../handManager/handsv1/AnimationPlayer"
@onready var handsv_1 = $"../../handManager/handsv1"
@onready var swordCollider = $"../../handManager/handsv1/armsrig/Skeleton3D/arm/Area3D/collider"
@onready var marker_3d = $"../../Marker3D"


const slashes = preload("res://scenes/player/weapons/swordSlashes.tscn")
var current_animation = "idle"
var canSwing = true
var canChain = false
var inputQueued = false
@onready var label = $"../../UI 2"

var meleeDamage: float = 40
var spinDamageMax : float = 70
var slashDamage: float = 15
var slashSpeed : float = 30


signal spinReleased



func _ready():
	set_animation_speed(1.5)
	swordCollider.disabled =true


# Function to adjust animation speed
func set_animation_speed(speed: float):
	var animation_speed = speed
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
			swordCollider.disabled = false
		elif canChain and inputQueued:
			if current_animation == "heavySwingRight":
				current_animation = "swingLeft"
				swordAnim.play("swingLeft")
				audio_manager.slash()
				swordCollider.disabled = false
			elif current_animation == "swingLeft":
				current_animation = "transition"
				swordAnim.play("transition")
				swordCollider.disabled = false
			elif current_animation == "transition":
				current_animation = "heavySwingRight"
				swordAnim.play("heavySwingRight")
				audio_manager.slash()
				swordCollider.disabled = false
				

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
	swordCollider.disabled = false
	
func reset_sword_state():
	current_animation = "idle"
	swordAnim.play("idle")
	canSwing = true
	canChain = false
	inputQueued = false
	swordCollider.disabled = true
	

func uppercut():
	current_animation = "spinRelease"
	swordAnim.play("spinRelease")
	audio_manager.uppercut()
	swordCollider.disabled = false

func slamDown():
	current_animation = "transitionSlam"
	swordAnim.play("transitionSlam",-1,2,false)
	audio_manager.uppercut()
	swordCollider.disabled = false
	
func colliderOn():
	swordCollider.disabled = false

func _physics_process(delta):
	label.text = "current_animation: " + str(current_animation) + "\nInputQueued: " + str(inputQueued) + "\ncanChain: " + str(canChain)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "transitionSlam":
		current_animation = "slamSpin"
		swordAnim.play("slamSpin")
		swordCollider.disabled = false
	if anim_name == "spinRelease":
		reset_sword_state()
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
				swordCollider.disabled = false

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
				swordCollider.disabled = false
			else:
				reset_sword_state()

#func spawn_projectile():
	#print("spawned")
	#var projectile = slashes.instantiate()
	#projectile.set_speed(slashSpeed)
	#projectile.position = marker_3d.global_position
	#projectile.transform.basis = marker_3d.global_transform.basis
	#add_child(projectile)
	#

