extends Node3D

@onready var dash_fx = $dashFx
@onready var sword_fx = $swordFx
@onready var draw_sword = $drawSword
@onready var max_draw = $maxDraw
@onready var launch_fx = $launchFx
@onready var uppercut_fx = $uppercutFX
@onready var drop_down_fx = $dropDownFx

func _ready():
	pass 

func dash():
	dash_fx.pitch_scale = randf_range(.99, 1.01)
	dash_fx.play()

func slash():
	sword_fx.pitch_scale = randf_range(.96 , 1.02)
	sword_fx.play()
func launch():
	launch_fx.volume_db = 0.0
	launch_fx.pitch_scale = randf_range(.92, 1.01)
	launch_fx.play()
func maxDrawReached():
	draw_sword.play()
func uppercut():
	uppercut_fx.play()
	launch_fx.volume_db = -10.0
	launch_fx.play()

func drop():
	drop_down_fx.play()
func _process(delta):
	pass
