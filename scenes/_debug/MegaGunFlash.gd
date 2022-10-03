extends ColorRect

const DURATION := 0.08 # TODO El tiempo hace que se oculten las explosiones ¿Será que debiera ser menos el flash o más la explosión?


func _ready():
	visible = false


func _flash():
	visible = true
	await get_tree().create_timer(DURATION, false).timeout
	visible = false


func _on_Player_mega_gun_shot():
	if not visible:
		_flash()
