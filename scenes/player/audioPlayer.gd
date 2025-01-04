extends Node3D

@onready var dash_fx = $dashFx
@onready var sword_fx = $swordFx
@onready var draw_sword = $drawSword


func _ready():
	pass 

func dash():
	dash_fx.pitch_scale = randf_range(0.70, .77)
	dash_fx.play()
func slash():
	sword_fx.pitch_scale = randf_range(.95 , 1.05)
	sword_fx.play()

func maxDrawReached():
	draw_sword.play()

func _process(delta):
	pass
