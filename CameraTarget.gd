@tool
@icon("targe.svg")
extends Marker2D
class_name CameraTarget2D

@export var strength : float = 1.0
@export var active :bool=true
@export var visible_in_game : bool = false

func _ready():
	if Engine.is_editor_hint(): return
	add_to_group("camera targets")

func _draw():
	if not Engine.is_editor_hint() and not visible_in_game: return
	draw_circle(Vector2.ZERO,36, Color.RED)
	draw_circle(Vector2.ZERO,24, Color.WHITE)
	draw_circle(Vector2.ZERO,12, Color.RED)
