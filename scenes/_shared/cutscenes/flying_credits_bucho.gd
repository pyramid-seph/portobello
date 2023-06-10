extends AnimatedSprite2D


@onready var _viewport_width: float = get_viewport_rect().size.x


func _ready() -> void:
	position.x = _viewport_width / 2


func _on_timer_timeout() -> void:
	position.x += -3 if (randi() % 10) == 0 else 3
	if position.x <=  _viewport_width / 4.0:
		position.x += 3
	elif position.x >= (_viewport_width / 4.0) * 3:
		position.x -= 3
