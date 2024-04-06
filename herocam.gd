extends Camera2D
class_name HeroCam2D

@export var sway_strength :float= 0.0
@export var shake_speed :float= 10.0
@export var shake_decay :float= 5.0
@onready var noise = FastNoiseLite.new()
@onready var shake_strength :float= sway_strength

var bounds_rect : Rect2 :
	set(b):
		bounds_rect = b
		limit_left = int(b.position.x)
		limit_right=int(b.end.x)
		limit_bottom=int(b.end.y)
		limit_top=int(b.position.y)
	get:
		return bounds_rect

static var MAIN : HeroCam2D
func _ready():
	#TODO: Add a camera shake option to options screens
	add_to_group("cameras")
	noise.seed = randi()
	noise.frequency = 2
	MAIN = self
	update_global_shake()

var global_shake_mul := 1.0
func update_global_shake():
	var ini = get_node("/root/_INIT")
	if ini:
		if "camera_shake" in ini.data:
			global_shake_mul = ini.data.camera_shake
		else:
			ini.data["camera_shake"] = 1.0

func _exit_tree():
	if is_queued_for_deletion() and MAIN == self:
		MAIN = null
		
func _process(delta):
	shake_strength = lerp(shake_strength, sway_strength, shake_decay * delta)
	offset = get_noise_offset(delta)
	
var noise_i :float= 0.0
func get_noise_offset(delta: float)-> Vector2:
	noise_i += delta * shake_speed
	return Vector2\
			(
				noise.get_noise_2d(1,noise_i)* shake_strength * global_shake_mul,
				noise.get_noise_2d(100,noise_i)*shake_strength * global_shake_mul
			)

func shake(strength := 50.0, decay := 5.0):
	if strength > shake_strength: shake_strength = strength
	if decay < shake_decay: shake_decay = decay

func still():
	shake_strength = 0
	
var bounds_first_time :bool= true
func set_bounds(bounds: Rect2, time:=0.3):
	if bounds_first_time or is_zero_approx(time):
		self.bounds_rect = bounds
		reset_smoothing()
		bounds_first_time = false
		return
	var tween = create_tween()
	tween.tween_property(self, "bounds_rect", bounds, time)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_CUBIC)

var minimum_zoom : Vector2 = Vector2(1,1)
var maximum_zoom : Vector2 = Vector2(1,1)
var zoom_first_time:bool=true
func set_zoom(new_zoom: Vector2, time:=0.3):
	new_zoom = new_zoom.clamp(minimum_zoom,maximum_zoom)
	if zoom_first_time or is_zero_approx(time):
		zoom = new_zoom
		zoom_first_time = false
		return
	var tween = create_tween()
	tween.tween_property(self, "zoom",new_zoom,time)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_CUBIC)
	
