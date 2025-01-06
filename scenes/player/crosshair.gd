extends Node2D

@export var crosshair_texture: Texture
@export var crosshair_size: Vector2 = Vector2(32, 32)

var crosshair_position: Vector2

func _ready():
	# Set the initial position of the crosshair to the center of the screen
	crosshair_position = get_viewport().size / 2

func _draw():
	# Draw the crosshair at the center of the screen
	if crosshair_texture:
		draw_texture(crosshair_texture, crosshair_position - crosshair_size / 2)

func _process(delta):
	# Update the crosshair position if needed (centered on the screen)
	crosshair_position = get_viewport().size / 2
	update()  # Call to redraw the crosshair
