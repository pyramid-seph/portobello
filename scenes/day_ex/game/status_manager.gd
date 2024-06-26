extends TextureRect


const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

const _atk_debuff_texture = preload("res://art/day_ex/battle_status_atk_debuff.png")
const _atk_buff_texture = preload("res://art/day_ex/battle_status_atk_buff.png")
const _def_debuff_texture = preload("res://art/day_ex/battle_status_def_debuff.png")
const _def_buff_texture = preload("res://art/day_ex/battle_status_def_buff.png")
const _spd_debuff_texture = preload("res://art/day_ex/battle_status_spd_debuff.png")
const _spd_buff_texture = preload("res://art/day_ex/battle_status_spd_buff.png")
const _love_texture = preload("res://art/day_ex/battle_status_love.png")
const _poison_texture = preload("res://art/day_ex/battle_status_poison.png")

const DISPLAY_DURATION_SEC: float = 1.0

var _curr_status_effects_textures: Array[Texture2D]
var _curr_displayed_texture_index: int
var _status_effect_hp: int
var _status_effect_love: bool

@onready var _timer: Timer = $Timer
@onready var _target: Fighter = owner as Fighter


func _ready() -> void:
	texture = null


func inflict_status_effects(action: BattleAction) -> void:
	if not action.inflicts_any_status_effect() or not _target:
		return
	
	var target_stats: Stats = _target.get_stats()
	var inflict: bool = \
			randi() % action.get_hit_chance_percent() <= target_stats.luck
	if inflict:
		pass
	_update_textures_array()


func on_death() -> void:
	_curr_status_effects_textures.clear()
	texture = null


func on_end_of_turn() -> void:
	_apply_end_of_turn_status_effects()
	_update_remaining_turns()
	_update_textures_array()


func _apply_end_of_turn_status_effects() -> void:
	# TODO
	pass


func _update_remaining_turns() -> void:
	# TODO
	pass


func _update_textures_array() -> void:
	# TODO
	pass
	#if action.buffs_attack():
		#_curr_status_effects_textures.append(_poison_texture)
	#elif action.debuffs_attack():
		#_curr_status_effects_textures.append(_poison_texture)
	#if action.buffs_deffense():
		#_curr_status_effects_textures.append(_def_buff_texture)
	#elif action.debuffs_deffense():
		#_curr_status_effects_textures.append(_def_debuff_texture)
	#if action.buffs_speed():
		#_curr_status_effects_textures.append(_spd_buff_texture)
	#elif action.debuffs_speed():
		#_curr_status_effects_textures.append(_spd_debuff_texture)
	#if action.inflicts_love():
		#_curr_status_effects_textures.append(_love_texture)
	#if action.inflicts_poison():
		#_curr_status_effects_textures.append(_poison_texture)


func _on_timer_timeout() -> void:
	var status_effects_count: int = _curr_status_effects_textures.size()
	if status_effects_count == 0:
		return
	
	var next: int = _curr_displayed_texture_index + 1
	_curr_displayed_texture_index = wrapi(next, 0, status_effects_count)
	texture = _curr_status_effects_textures[_curr_displayed_texture_index]
