extends ColorRect

const DURATION: float = 0.08 # TODO El tiempo hace que se oculten las explosiones ¿Será que debiera ser menos el flash o más la explosión? O tal vez mover la Z de explosiones a adelante del efecto.

var _tween: Tween


func _ready() -> void:
	visible = false


func _flash() -> void:
	visible = true
	if _tween:
		_tween.stop()
	_tween = create_tween()
	_tween.tween_callback(func(): visible = false).set_delay(DURATION)


func _on_Player_mega_gun_shot() -> void:
	if not visible:
		_flash()
