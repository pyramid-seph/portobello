class_name HiveDrone
extends BaseDay03Enemy


@onready var _gun := $Gun as Gun
@onready var _shield := $Shield


func _ready() -> void:
	super()
	_update_shield_state()


func _on_bullet_immunity_changed() -> void:
	_update_shield_state()


func _on_set_world(new_world) -> void:
	_gun.world = new_world


func shoot() -> bool:
	return _gun.shoot(Vector2.DOWN)


func _update_shield_state() -> void:
	_shield.visible = is_immune_to_bullets
