@tool
extends Node2D
class_name CameraFob

@export var radius: float = 36.0:
	set(r):
		radius = r
		queue_redraw()
		
func _draw():
	if not Engine.is_editor_hint(): return
	draw_arc(Vector2.ZERO,radius,0,TAU,12,Color.YELLOW,4)
	
func _ready():
	if Engine.is_editor_hint(): return
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = radius
	area.add_child(shape)
	area.collision_layer=8
	area.collision_mask=128
	add_child(area)
