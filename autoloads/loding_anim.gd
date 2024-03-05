extends HBoxContainer


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_on_visibility_changed()


func _on_visibility_changed() -> void:
	if not is_node_ready():
		return
	
	if visible:
		_animation_player.play("default")
	else:
		_animation_player.stop()
