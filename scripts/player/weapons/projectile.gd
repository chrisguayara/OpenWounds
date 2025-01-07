extends CharacterBody3D

var speed 

func _physics_process(delta):
	position += transform.basis * Vector3(0,0, -speed) * delta
	

func _ready():
	print("yoo")

func set_speed(projectilespeed: int):
	speed = projectilespeed
