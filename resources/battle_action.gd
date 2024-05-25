@tool
class_name BattleAction
extends Resource


enum AttackType {
	NORMAL,
	ABILITY,
}

enum CostType {
	NONE,
	MP,
	SCRAPS
}

enum DamageType {
	HP_POINTS,
	HP_PERCENT,
}

enum TargetType {
	ENEMIES,
	SELF,
}

enum StatusEffectType {
	STATS,
	LOVE,
}

@export var _attack_type: AttackType
@export var _target: TargetType
@export var _action_name: String
@export_multiline var _info: String
@export var _required_level: int
@export var _cost_type: CostType:
	set(value):
		_cost_type = value
		notify_property_list_changed()
@export var _mp_cost: int
@export var _scraps_cost: int
@export var _damage_type: DamageType:
	set(value):
		_damage_type = value
		notify_property_list_changed()
@export var _damage_points: int
@export_range(-1.0, 1.0, 0.01) var _damage_percent: float
@export var _damage_ignores_atk_stat: bool
@export_range(0.0, 1.0, 0.01) var _hit_chance: float = 1.0

@export_group("Animation")
@export var _sprites: Array[Texture2D]
@export var _duration_sec: float = 1.0
@export_color_no_alpha var _target_flash_color: Color = Color.WHITE
@export var _screen_flash_color: Color = Color.TRANSPARENT
@export var _shake_screen: bool

@export_group("Status Effect", "_status_effect")
@export var _status_effect_type: StatusEffectType:
	set(value):
		_status_effect_type = value
		notify_property_list_changed()
@export var _status_effect_attack: int
@export var _status_effect_defense: int
@export var _status_effect_speed: int


func get_attack_type() -> AttackType:
	return _attack_type


func get_target() -> TargetType:
	return _target


func get_action_name() -> String:
	return _action_name


func get_info() -> String:
	return _info


func get_required_level() -> int:
	return _required_level


func get_cost_type() -> CostType:
	return _cost_type


func get_mp_cost() -> int:
	return _mp_cost


func get_scraps_cost() -> int:
	return _scraps_cost


func get_damage_type() -> DamageType:
	return _damage_type


func get_damage_points() -> int:
	return _damage_points


func get_damage_percent() -> float:
	return _damage_percent


func damage_ignores_atk_stat() -> bool:
	return _damage_ignores_atk_stat


func get_hit_chance() -> float:
	return _hit_chance


func get_sprites() -> Array[Texture2D]:
	return _sprites


func get_duration_sec() -> float:
	return _duration_sec


func get_target_flash_color() -> Color:
	return _target_flash_color


func get_screen_flash_color() -> Color:
	return _screen_flash_color


func shake_screen() -> bool:
	return _shake_screen


func get_status_effect_type() -> StatusEffectType:
	return _status_effect_type


func get_status_effect_attack() -> int:
	return _status_effect_attack


func get_status_effect_defense() -> int:
	return _status_effect_defense


func get_status_effect_speed() -> int:
	return _status_effect_speed


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"_damage_points":
			if _damage_type != DamageType.HP_POINTS:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"_damage_percent":
			if _damage_type != DamageType.HP_PERCENT:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"_mp_cost":
			if _cost_type != CostType.MP:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"_scraps_cost":
			if _cost_type != CostType.SCRAPS:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"_status_effect_attack", \
		"_status_effect_defense", \
		"_status_effect_speed":
			if _status_effect_type != StatusEffectType.STATS:
				property.usage = PROPERTY_USAGE_NO_EDITOR
