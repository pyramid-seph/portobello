extends IntroLogo

@export_range(0.1, 5.0, 0.01, "or_greater")
var duration_sec: float = 1.0

@onready var _timer: Timer = $Timer


func reset() -> void:
	_timer.stop()
	hide()


func _play() -> void:
	show()
	_timer.start(duration_sec)


func _on_timer_timeout() -> void:
	finished.emit()
