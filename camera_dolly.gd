@tool
extends Node2D
class_name CameraDolly2D

@export var lerp_speed:= 0.5
@export var draw_in_game: bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	var blend = pow(0.5, delta * lerp_speed)
	var cam_targets = get_tree().get_nodes_in_group("camera targets")
	var target_position := Vector2.ZERO
	var total_weights := 0.0
	for t in cam_targets:
		var tg = t as CameraTarget2D
		if not tg.active: continue
		target_position += tg.global_position * tg.strength
		total_weights += tg.strength
	if total_weights > 0:
		target_position /= total_weights
		global_position = lerp(target_position, global_position, blend)

func _draw():
	if not Engine.is_editor_hint() and not draw_in_game: return
	draw_arc(Vector2.ZERO,40,0, TAU,12,Color.BLACK,5)
	draw_line(Vector2(0,-45),Vector2(0,45),Color.BLACK,5)
	draw_line(Vector2(-45,0),Vector2(45,0),Color.BLACK,5)
	draw_arc(Vector2.ZERO,40,0, TAU,12,Color.WHITE,2)
	draw_line(Vector2(0,-45),Vector2(0,45),Color.WHITE,2)
	draw_line(Vector2(-45,0),Vector2(45,0),Color.WHITE,2)
