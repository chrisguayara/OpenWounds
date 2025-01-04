extends Node3D

var AreaDamage: int = 34
@onready var audio_manager = $"../../../../audio_manager"

@onready var swordAnim = $"../../handManager/handsv1/AnimationPlayer"

var current_animation = "idle"
var canSwing = true
var canChain = false
var inputQueued = false
@onready var label = $"../../UI 2"

var animation_speed = 1.0  # Default speed (1.0 is normal speed)

func _ready():
	# Set the default speed for all animations
	set_animation_speed(1.3)

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

func swordSpin():
	pass

func _physics_process(delta):
	label.text = "current_animation: " + str(current_animation) + "\nInputQueued: " + str(inputQueued) + "\ncanChain: " + str(canChain)

# Handle animation finishing logic in this function
func _on_animation_player_animation_finished(anim_name):
	
	
	if anim_name == "heavySwingRight" or anim_name == "swingLeft" or anim_name == "transition":
		canSwing = true  # Allow the next swing after animation finishes
		
		if anim_name == "heavySwingRight":
			# If no input was queued, transition to idle
			if !inputQueued:
				print("YO!!!!")
				current_animation = "idle"
				swordAnim.play("idle")
				canSwing = true
				canChain = false
				inputQueued = false
			else:
				# If input was queued, continue chaining the animation
				current_animation = "swingLeft"
				swordAnim.play("swingLeft")
				audio_manager.slash()
				canSwing = false
				canChain = true

		elif anim_name == "swingLeft":
			# Transition to next animation (e.g., transition)
			current_animation = "transition"
			swordAnim.play("transition")
			canSwing = false  # Disable swinging while transitioning

		elif anim_name == "transition":
			# After transition, check if inputQueued is true to chain back to heavySwingRight
			if inputQueued:
				current_animation = "heavySwingRight"
				swordAnim.play("heavySwingRight")
				audio_manager.slash()
				canSwing = false
				canChain = true
				inputQueued = false  # Reset inputQueued after continuing the chain
			else:
				current_animation = "idle"
				swordAnim.play("idle")
				canChain = false  # Reset canChain
				inputQueued = false  # Reset inputQueued
