@tool
extends Marker2D
class_name CameraGoal2D

@export var visible_in_game:bool=false

func _draw():
	if not Engine.is_editor_hint() and not visible_in_game: return
	draw_circle(Vector2.ZERO,36, Color.ORANGE)
	draw_circle(Vector2.ZERO,24, Color.WHITE)
	draw_circle(Vector2.ZERO,12, Color.ORANGE)
	
@export var alacrity :float= 0.25
@export var targets : Dictionary
func lookat(target):
	if not target in targets: return
	target = get_node(targets[target]) as Node2D
	if not target: return
	var p = get_parent() as Node2D
	if not p: return
	target = p.to_local(target.global_position)
	var tween = create_tween()
	tween.tween_property(self, "position", target,alacrity)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
