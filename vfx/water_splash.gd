extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CPUParticles2D.emitting = true
	await $CPUParticles2D.finished
	queue_free()
	pass # Replace with function body.
