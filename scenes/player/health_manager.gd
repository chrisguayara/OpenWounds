extends Node3D

var max_health = 100
var current_health = 100
@onready var hurtbox = $"../CollisionShape3D"

func takeDamage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func die():
	print("player has died")
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
