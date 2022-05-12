extends ColorRect

const DURATION := 0.08


func _ready():
	visible = false


func _flash():
	visible = true
	yield(get_tree().create_timer(DURATION, false), "timeout")
	visible = false


func _on_Player_mega_gun_shot():
	if not visible:
		_flash()
