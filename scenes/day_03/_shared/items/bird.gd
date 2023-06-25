extends MovingItem


const MIN_STAMINA: int = 5
const BASE_STAMINA: int = 20


func _on_pick_up(picker) -> void:
	if picker.has_method("add_stamina"):
		picker.add_stamina(randi() % BASE_STAMINA + MIN_STAMINA)
