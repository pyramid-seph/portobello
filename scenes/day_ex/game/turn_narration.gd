class_name TurnNarration
extends RefCounted


const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")

var narrator: BattleNarrationBox


func wait_until_read() -> void:
	if narrator:
		await narrator.wait_until_read()


func turn(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_FIGHTER_TURN", { "name": who })


func attack(attacker: String, attack_name: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_COMMAND_HURT", 
			{ "attacker": attacker, "attack": attack_name })


func cure(attacker: String, attack_name: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_COMMAND_CURE", 
			{ "attacker": attacker, "attack": attack_name })


func pass_turn(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_COMMAND_PASS", { "target": who })


func evade(target: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_EVADE", { "target": target })


func charmed(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_CHARM_INFLICTED", 
			{ "target": who })


func already_charmed(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_CHARM_ALREADY", 
			{ "target": who })


func charm_clear(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_CHARM_CLEAR",
			{ "target": who })


func poisoned(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_POISON_INFLICTED",
			{ "target": who })


func already_poisoned(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_POISON_ALREADY", 
			{ "target": who })


func poison_damage(who: String, damage: int) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_POISON_DAMAGE", 
			{ "target": who, "damage": damage })


func poison_clear(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STATUS_EFFECT_POISON_CLEAR",
			{ "target": who })


func devour_damage(target: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_DEVOUR_DAMAGE", { "target": target })


func hp_damage(target: String, damage: int) -> void:
	_narrate("RPG_BATTLE_NARRATION_HP_DAMAGE", 
			{ "target": target, "damage": damage })


func hp_recover(target: String, damage: int) -> void:
	_narrate("RPG_BATTLE_NARRATION_HP_RECOVERY", 
			{ "target": target, "damage": damage })


func murdered(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_DEAD_MURDERED", { "target": who })


func devoured(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_DEAD_DEVOURED", { "target": who })


func flee_attempt(who: String, how_many: int) -> void:
	var msg: String = "RPG_BATTLE_NARRATION_FLEE_ATTEMPT_%s" % \
			("MANY" if how_many > 1 else "SINGLE")
	_narrate(msg, { "target": who })


func flee_fail(who: String, how_many: int) -> void:
	var msg: String = "RPG_BATTLE_NARRATION_FLEE_FAIL_%s" % (
				"MANY" if how_many > 1 else "SINGLE")
	_narrate(msg, { "target": who })


func flee_success(who: String, how_many: int) -> void:
	var msg: String = "RPG_BATTLE_NARRATION_FLEE_SUCCESS_%s" % (
			"MANY" if how_many > 1 else "SINGLE")
	_narrate(msg, { "target": who })


func atk_at_max(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_ATK_MAXIMIZED", { "target": who })


func atk_at_min(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_ATK_MINIMIZED", { "target": who })


func atk_buff(who: String, points: int) -> void:
	var msg: String = "RPG_BATTLE_NARRATION_STATUS_EFFECT_ATK_" % (
			"DEBUFF" if points < 0 else "BUFF")
	_narrate(msg, { "target": who, "points": points })


func atk_reset(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_ATK_NORMAL", { "target": who })


func def_at_max(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_DEF_MAXIMIZED", { "target": who })


func def_at_min(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_DEF_MINIMIZED", { "target": who })


func def_buff(who: String, points: int) -> void:
	var msg: String = "RPG_BATTLE_NARRATION_STATUS_EFFECT_DEF_" % (
			"DEBUFF" if points < 0 else "BUFF")
	_narrate(msg, { "target": who, "points": points })


func def_reset(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_DEF_NORMAL", { "target": who })


func spd_at_max(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_SPD_MAXIMIZED", { "target": who })


func spd_at_min(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_SPD_MINIMIZED", { "target": who })



func spd_buff(who: String, points: int) -> void:
	var msg: String = "RPG_BATTLE_NARRATION_STATUS_EFFECT_SPD_" % (
			"DEBUFF" if points < 0 else "BUFF")
	_narrate(msg, { "target": who, "points": points })


func spd_reset(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_STAT_SPD_NORMAL", { "target": who })


func not_enough_treats(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_NOT_ENOUGH_TREATS", { "target": who })


func not_enough_mp(who: String) -> void:
	_narrate("RPG_BATTLE_NARRATION_NOT_ENOUGH_MP", { "target": who })


func _narrate(what: String, format_values: Dictionary = {}) -> void:
	if narrator:
		narrator.say(what, format_values)
