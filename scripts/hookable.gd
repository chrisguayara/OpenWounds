extends Area3D

var is_hooked = false

func _ready():
	# Initialization logic
	pass

# Called when the raycast hits the object
func on_hooked():
	print("we did it")
		# You can add logic here to freeze the object's position or start any hook-related behavior.


func _on_area_entered(area):
	if not is_hooked:
		is_hooked = true
		print("Object " + name + " is now hooked!")
