extends GPUParticles2D


@export var _autostart: bool


func _ready() -> void:
	if _autostart:
		emitting = true


func _on_finished() -> void:
	queue_free()
