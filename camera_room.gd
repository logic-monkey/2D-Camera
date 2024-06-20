@tool
extends ReferenceRect
class_name CameraRoom2D

static var ACTIVE_ROOMS : Array[CameraRoom2D] = []

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
	area.area_exited.connect(_on_area_exited)
	

func _get_configuration_warnings():
	var warnings = []
	var has_collider:bool=false
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D: has_collider = true
	if not has_collider: warnings.append("Needs a collision shape to function")
	
@export var time_to_change : float = 0.3
@export var minimum_zoom : float = 1
@export var maximum_zoom : float = 1
@export var zoom_offset : float = 0.0
func _on_area_entered(area):
	camera_room_entered.emit()
	#if not HeroCam2D.MAIN: return
	#var r = get_global_rect()
	#HeroCam2D.MAIN.set_bounds(r, time_to_change)
	#HeroCam2D.MAIN.minimum_zoom = Vector2(minimum_zoom, minimum_zoom)
	#HeroCam2D.MAIN.maximum_zoom = Vector2(maximum_zoom,maximum_zoom)
	#HeroCam2D.MAIN.zoom_offset = Vector2(zoom_offset, zoom_offset)
	if self in ACTIVE_ROOMS: ACTIVE_ROOMS.erase(self)
	ACTIVE_ROOMS.append(self)
	enforce_cam(self)
	
func _on_area_exited(area):
	if self in ACTIVE_ROOMS:
		ACTIVE_ROOMS.erase(self)
		if ACTIVE_ROOMS.size() >= 1: enforce_cam(ACTIVE_ROOMS[-1])
	
signal camera_room_entered

func enforce_cam(room: CameraRoom2D):
	if not HeroCam2D.MAIN: return
	var r = room.get_global_rect()
	HeroCam2D.MAIN.set_bounds(r, time_to_change)
	HeroCam2D.MAIN.minimum_zoom = Vector2(room.minimum_zoom, room.minimum_zoom)
	HeroCam2D.MAIN.maximum_zoom = Vector2(room.maximum_zoom,room.maximum_zoom)
	HeroCam2D.MAIN.zoom_offset = Vector2(room.zoom_offset, room.zoom_offset)
