@tool
extends ReferenceRect
class_name CameraRoom2D

func _ready():
	#child_entered_tree.connect(update_configuration_warnings)
	update_configuration_warnings()
	if Engine.is_editor_hint(): return
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var area = Area2D.new()
	area.collision_layer = 128
	area.collision_mask = 8
	var colliders = []
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			colliders.append(c)
	for c in colliders:
		remove_child(c)
		area.add_child(c)
	add_child(area)
	area.area_entered.connect(_on_area_entered)
	

func _get_configuration_warnings():
	var warnings = []
	var has_collider:bool=false
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D: has_collider = true
	if not has_collider: warnings.append("Needs a collision shape to function")
	
@export var time_to_change : float = 0.3
func _on_area_entered(area):
	if not HeroCam2D.MAIN: return
	var r = get_global_rect()
	HeroCam2D.MAIN.set_bounds(r, time_to_change)
	
