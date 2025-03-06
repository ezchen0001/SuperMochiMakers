class_name VFX
const water_splash_tscn = preload("res://vfx/water_splash.tscn")

static func create_splash(pos) -> Node2D:
	var splash = water_splash_tscn.instantiate()
	splash.position = pos
	return splash
	
	
