extends Node2D

signal first_hit
signal win
signal hand_whack

@onready var _poly = $MochiPoly
@onready var _rice_poly = $RicePoly
@onready var _label = $Label
var original_pos = []
var started = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	key_pos_map = generate_key_pos_map()
	for v in _poly.polygon:
		original_pos.append(v)
	
	_randomize()
	
	pass # Replace with function body.

func _randomize():
	for i in range(_poly.polygon.size()):
		_poly.polygon[i] = original_pos[i] + Vector2(randf_range(-120,120),randf_range(-120,120))
	_update_closeness_transparency()
	_update_rice_poly()
func _update_rice_poly():
	_rice_poly.polygon = _poly.polygon
	_rice_poly.modulate = _poly.modulate

const POUND_RADIUS = 200
var pound_tween = null
var hurt_tween = null
func pound(x:float):
	
	$Impact.position = Vector2(x, 0)
	$Impact.modulate = Color.WHITE
	if pound_tween:
		pound_tween.kill()
	pound_tween = create_tween()
	pound_tween.tween_property($Impact, "modulate", Color.TRANSPARENT, 0.3)
	$Whack.play()
	print(abs(get_parent().get_node("Hand/Center").position.x-x))
	if not started:
		started = true
		first_hit.emit()
	
	# Hand hitting logic (for time penalty)
	if abs(get_parent().get_node("Hand/Center").position.x-x) < POUND_RADIUS:
		get_parent().get_node("Hand").color = Color.RED
		if hurt_tween:
			hurt_tween.kill()
		$Punch.play()
		hurt_tween = create_tween()
		hurt_tween.tween_property(get_parent().get_node("Hand"), "color", Color.WHITE, 0.5)
		hand_whack.emit()
	
	
	if wetness < 1:
		return
	for i in range(_poly.polygon.size()):
		var pound_dist = 1 - abs(_poly.polygon[i].x - x)/POUND_RADIUS/2
		pound_dist = clamp(pound_dist,0, 1)
		_poly.polygon[i] =  lerp(_poly.polygon[i], original_pos[i], pound_dist / 3)
	wetness -= 1
	if wetness < 1:
		_poly.modulate = Color.DIM_GRAY
	
	_update_closeness_transparency()
	_update_rice_poly()
	if not _label.visible and is_goal_reached():
		$Success.play()
		_label.visible = true
		win.emit()
		await get_tree().create_timer(7).timeout
		_randomize()
		_label.visible = false
		started = false 
		
		
	pass
var win_seq = true
var debounce = false
# Called every frame. 'delta' is the elapsed time since the previous frame.

var wetness = 3

const MAX_DIST_ERROR = 50
func is_goal_reached():
	for i in range(_poly.polygon.size()):
		if (original_pos[i] - _poly.polygon[i]).length() > MAX_DIST_ERROR:
			return false
	return true

func _update_closeness_transparency():
	var colors = []
	for i in range(_poly.polygon.size()):
		var dist_past_error = (original_pos[i] - _poly.polygon[i]).length() - MAX_DIST_ERROR
		if dist_past_error > 0:
			colors.append(lerp(Color(1,0,0), Color(0.9,0.9,0.6,0), clamp(dist_past_error/3,0,1)))
		else:
			colors.append(Color.WHITE)
	_poly.vertex_colors = PackedColorArray(colors)
	

func make_wet():
	wetness = 3
	_poly.modulate = Color.WHITE
	_update_rice_poly()
var key_pos_map = {}
func _process(delta: float) -> void:
	var key_down = false
	var pos = 0
	for key in key_pos_map:
		if Input.is_key_pressed(key):
			pos = key_pos_map[key]
			key_down = true
	if key_down:
		if not debounce:
			debounce = true
			pound(pos)
	else:
		debounce = false
	pass
	
var rows = [
	[KEY_Q,KEY_W,KEY_E,KEY_R,KEY_T,KEY_Y,KEY_U,KEY_I,KEY_O,KEY_P,KEY_BRACKETLEFT,KEY_BRACKETRIGHT],
	[KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON, KEY_QUOTEDBL],
	[KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M, KEY_COMMA, KEY_PERIOD, KEY_SLASH]
]
func generate_key_pos_map():
	var map = {}
	var offset = [0,0.3,0.8]
	for i in rows.size():
		var row = rows[i]
		for j in row.size():
			map[row[j]] = (j + offset[i] - 5) * 170
	return map
