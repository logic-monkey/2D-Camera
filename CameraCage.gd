@tool
extends Marker2D
class_name CameraCage

var target: Node2D
var body: CharacterBody2D

func _ready():
	if Engine.is_editor_hint(): return
	await get_tree().process_frame
	acquire_target()
	catch_up()
	if HeroCam2D.MAIN: HeroCam2D.MAIN.reset_smoothing()
	create_cam_cage()
	# Activate Camera Target, once we have those.

func acquire_target():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() >=1: 
		target = players[0].get_node("CameraGoal2D") as Node2D
		if target: body = target.get_parent()
	
func catch_up():
	if target: global_position = target.global_position
	
var push_right :bool= true
var jump_free :bool= true
func _process(_delta):
	if Engine.is_editor_hint(): return
	if not target: 
		acquire_target()
		if not target: return
	if push_right:
		if global_position.x < target.global_position.x:
			global_position.x = target.global_position.x
	else:
		if global_position.x > target.global_position.x:
			global_position.x = target.global_position.x
	if body.is_on_floor():
		global_position.y = target.global_position.y
		jump_free = true
	elif not jump_free:
		global_position.y = target.global_position.y
		
	var speed = body.velocity.length()
	speed /= SharedPhysics.scale
	speed = clamp(speed, zoom_speed_minimum, zoom_speed_maximum)
	speed -= zoom_speed_minimum
	speed /= (zoom_speed_maximum - zoom_speed_minimum)
	cam_target.desired_scale = lerp(zoom_maximum, zoom_minimum, speed)
	
func _on_verticle_bumper_entered(area):
	#if area.owner != body: return
	jump_free = false
	
func _on_left_bumper_entered(area):
	#if area.owner != body: return
	push_right = false
	
func _on_right_bumper_entered(area):
	#if area.owner != body: return
	push_right = true

@export_group("Cage Bumper", "bumper_")
@export var bumper_draw_in_game : bool = false
@export var bumper_cage_vertical_offset : float = 0.0:
	set(cvo):
		bumper_cage_vertical_offset = cvo
		queue_redraw()
@export var bumper_cage_height : float = 360.0:
	set(ch):
		bumper_cage_height = ch
		queue_redraw()
@export var bumper_cage_width : float = 504.0:
	set(cw):
		bumper_cage_width = cw
		queue_redraw()
@export var bumper_thickness : float = 72.0:
	set(th):
		bumper_thickness = th
		queue_redraw()
@export var bumper_line_thickness : float = 4.0:
	set(th):
		bumper_line_thickness = th
		queue_redraw()
@export var bumper_line_color : Color = Color.YELLOW:
	set (c):
		bumper_line_color = c
		queue_redraw()		
		
@export_group("Camera Zoom", "zoom_")
@export var zoom_minimum := 0.75
@export var zoom_maximum := 2.0
#@export var zoom_middle := 1.0
@export var zoom_speed_minimum : float = 3
@export var zoom_speed_maximum : float = 10
#@export var zoom_speed_middle : float = 5

func _draw():
	if not Engine.is_editor_hint() and not bumper_draw_in_game: return
	var outer_rect = Rect2(\
			-(bumper_cage_width/2),
			-(bumper_cage_height/2)+bumper_cage_vertical_offset,
			bumper_cage_width,
			bumper_cage_height
		)
	var inner_rect = Rect2(outer_rect)
	inner_rect.position.x += bumper_thickness
	inner_rect.position.y += bumper_thickness
	inner_rect.size.x -= bumper_thickness * 2
	inner_rect.size.y -= bumper_thickness * 2
	draw_rect(outer_rect, bumper_line_color,false,bumper_line_thickness)
	draw_rect(inner_rect, bumper_line_color,false,bumper_line_thickness)
	draw_line(Vector2(0, inner_rect.position.y), Vector2(0, inner_rect.end.y),\
			bumper_line_color,bumper_line_thickness,false)
	draw_line(Vector2(inner_rect.position.x, 0), Vector2(inner_rect.end.x, 0),\
			bumper_line_color,bumper_line_thickness,false)

func create_cam_cage():
	var r_top = Rect2(\
			-(bumper_cage_width/2),
			-(bumper_cage_height/2)+bumper_cage_vertical_offset,
			bumper_cage_width,
			bumper_thickness
			)
	var r_bottom = Rect2(\
			(-bumper_cage_width/2),
			(bumper_cage_height/2)+bumper_cage_vertical_offset-bumper_thickness,
			bumper_cage_width,
			bumper_thickness
			)
	var r_left = Rect2(\
			-(bumper_cage_width/2),
			-(bumper_cage_height/2)+bumper_cage_vertical_offset,
			bumper_thickness,
			bumper_cage_height
			)
	var r_right = Rect2(\
			(bumper_cage_width/2)-bumper_thickness,
			-(bumper_cage_height/2)+bumper_cage_vertical_offset,
			bumper_thickness,
			bumper_cage_height
			)
	for box in [r_top, r_bottom]:
		attach_bumper(box, _on_verticle_bumper_entered)
	attach_bumper(r_left,_on_left_bumper_entered)
	attach_bumper(r_right,_on_right_bumper_entered)
	cam_target = CameraTarget2D.new()
	cam_target.visible_in_game = bumper_draw_in_game
	add_child(cam_target)

var cam_target : CameraTarget2D

func attach_bumper(rect:Rect2, alert:Callable):
	var area = Area2D.new()
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = rect.size
	shape.position = rect.get_center()
	area.add_child(shape)
	area.collision_layer = 128
	area.collision_mask = 8
	area.area_entered.connect(alert)
	add_child(area)
