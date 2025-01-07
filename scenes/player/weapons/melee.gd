extends Area3D

var damage = 34
@onready var audio_manager = $"../../../../../../../../audio_manager"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	audio_manager.successfulHit()
	if body.has_method("takeDamage"):
		body.takeDamage(damage)
		audio_manager.successfulHit()


func _on_area_entered(area):
	audio_manager.normalHit()
	
