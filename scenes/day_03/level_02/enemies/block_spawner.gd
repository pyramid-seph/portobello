extends Marker2D


@export var _block: PackedScene

@onready var _timer := $Timer as Timer


func activate() -> void:
	pass


func deactivate() -> void:
	pass


func _on_timer_timeout() -> void:
	pass # Replace with function body.
