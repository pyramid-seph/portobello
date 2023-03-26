class_name Ufo
extends MovingDay03Enemy


@onready var _bottom_gun := $BottomGun as Gun
@onready var _top_gun := $TopGun as Gun


func _on_set_world(new_world) -> void:
	_bottom_gun.world = new_world
	_top_gun.world = new_world


func fire_bottom_gun() -> bool:
	return _bottom_gun.shoot(Vector2.DOWN)


func fire_top_gun() -> bool:
	return _top_gun.shoot(Vector2.UP)
