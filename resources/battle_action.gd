@tool
class_name BattleAction
extends Resource


const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

enum Target {
	SINGLE_ENEMY,
	SELF,
}

enum Consumable {
	NOTHING,
	MP,
	SCRAPS,
}

enum PhysicalDamage {
	NONE,
	LOSE_HP_POINTS,
	LOSE_HP_PERCENT,
	RECOVER_HP_POINTS,
	DEVOUR,
}

@export var _action_name: String
@export var _info: String
@export var _target: Target
@export var _consumes: Consumable:
	set(value):
		_consumes = value
		notify_property_list_changed()
@export_range(1, 100, 1, "hide_slider") var _cost: int = 1
@export var _physical_damage: PhysicalDamage:
	set(value):
		_physical_damage = value
		notify_property_list_changed()
@export_range(1, 99999, 1, "hide_slider") var _damage_points: int = 1
@export_range(0.05, 1.0, 0.01) var _damage_percent: float = 0.5
@export_range(0.0, 1.0, 0.01) var _hit_chance: float = 1.0
@export var _devour_attack: bool

@export_group("Status Effect", "_status_effect")
## Lose some hp for 3 turns after completing their turn.
@export_range(0, 99999, 1, "hide_slider") var _status_effect_poison_damage: int
@export var _status_effect_attack: int ## Modify target ATT stat for 3 turns.
@export var _status_effect_defense: int ## Modify target DEF stat for 3 turns.
@export var _status_effect_speed: int ## Modify target SPD stat for 3 turns.
@export var _status_effect_love: bool ## Turn target against their party.

@export_group("Animation")
@export var _sprites: Array[Texture2D]
@export var _duration_sec: float = 1.0
@export var _screen_flash_color: Color = Color.TRANSPARENT
@export var _shake_screen: bool

## 0 means evade, positive means damage, negative means recovery
func calculate_hp_damage(attacker: Fighter, target: Fighter) -> int:
	var damage: int = 0
	if _physical_damage == PhysicalDamage.NONE:
		return damage
	
	var attacker_stats: Stats = attacker.get_stats()
	var target_stats: Stats = target.get_stats()
	
	if _physical_damage == PhysicalDamage.LOSE_HP_POINTS:
		var extra_damage: int = 0
		if randi() % get_hit_chance_percent() <= target_stats.get_lck():
			extra_damage = -(randi() % (floori(float(target_stats.get_def()) / float(attacker_stats.get_atk())) + 5))
		else:
			extra_damage = randi() % (floori(float(attacker_stats.get_atk()) / float(target_stats.get_def())) + 5)
		damage = maxi(1, _damage_points + extra_damage)
		if target.get_curr_hp() < damage:
			damage = target.get_curr_hp()
	elif _physical_damage == PhysicalDamage.LOSE_HP_PERCENT:
		damage = maxi(1, target.get_curr_hp() * _damage_percent)
		if target.get_curr_hp() < damage:
			damage = target.get_curr_hp()
	elif _physical_damage == PhysicalDamage.DEVOUR:
		damage = _damage_points
	elif _physical_damage == PhysicalDamage.RECOVER_HP_POINTS:
		damage = _damage_points * -1
	return damage


func inflict_status(attacker: Fighter, target: Fighter) -> bool:
	var target_stats: Stats = target.get_stats()
	var inflict: bool = randi() % get_hit_chance_percent() <= target_stats.get_lck()
	if inflict:
		# TODO buff/debuff
		# Stats can be buffed/debuffed 7 points from their initial value.
		# Example: Bug initial attack is 5, this means its minimum and maximum
		# attacks are 1 and 12 (stats cannot be less than 1)
		pass
	
	 #int rul = Math.abs( random.nextInt() ) % habilidadesBucho[tecnicaElegida].efectividad;
						#System.out.println( rul
								#+ "\n" + enemigo[enemigoElegido].suerte);
						#efectivo = (rul <=
								#enemigo[enemigoElegido].suerte ? false : true );
	
	return inflict


func get_target() -> Target:
	return _target


func get_action_name() -> String:
	return _action_name


func get_info() -> String:
	return _info


func get_consumes() -> Consumable:
	return _consumes


func get_cost() -> int:
	return _cost


func get_physical_damage() -> PhysicalDamage:
	return _physical_damage


func get_damage_points() -> int:
	return _damage_points


func get_damage_percent() -> float:
	return _damage_percent


func get_hit_chance() -> float:
	return _hit_chance


func get_hit_chance_percent() -> int:
	return ceili(_hit_chance * 100.0)


func is_devour_attack() -> bool:
	return _devour_attack


func get_sprites() -> Array[Texture2D]:
	return _sprites


func get_duration_sec() -> float:
	return _duration_sec


func get_screen_flash_color() -> Color:
	return _screen_flash_color


func shake_screen() -> bool:
	return _shake_screen


func get_status_effect_attack() -> int:
	return _status_effect_attack


func get_status_effect_defense() -> int:
	return _status_effect_defense


func get_status_effect_speed() -> int:
	return _status_effect_speed


func get_poison_damage() -> int:
	return _status_effect_poison_damage


func inflicts_poison() -> bool:
	return _status_effect_poison_damage < 0


func inflicts_love() -> bool:
	return _status_effect_love


func buffs_attack() -> bool:
	return _status_effect_attack > 0


func debuffs_attack() -> bool:
	return _status_effect_attack < 0


func buffs_deffense() -> bool:
	return _status_effect_defense > 0


func debuffs_defense() -> bool:
	return _status_effect_defense < 0


func buffs_speed() -> bool:
	return _status_effect_speed > 0


func debuffs_speed() -> bool:
	return _status_effect_speed < 0


func inflicts_any_status_effect() -> bool:
	return _status_effect_attack != 0 or \
			_status_effect_defense != 0 or \
			_status_effect_speed != 0 or \
			inflicts_poison() or \
			inflicts_love()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		"_cost":
			if _consumes == Consumable.NOTHING:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"_damage_points":
			if _physical_damage != PhysicalDamage.LOSE_HP_POINTS and \
					_physical_damage != PhysicalDamage.RECOVER_HP_POINTS and \
					_physical_damage != PhysicalDamage.DEVOUR:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"_damage_percent":
			if _physical_damage != PhysicalDamage.LOSE_HP_PERCENT:
				property.usage = PROPERTY_USAGE_NO_EDITOR
