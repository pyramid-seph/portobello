class_name TurnOrderManager
extends RefCounted

const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const BattlefieldSide = preload("res://scenes/day_ex/game/battlefield_side.gd")

var _player_side: BattlefieldSide
var _enemy_side: BattlefieldSide
# A negative value means enemy. A positive value means player party.
# Zero is an invalid value.
# This stores positions, not indexes!
var _turns: Array[int]
var _curr_idx: int = -1
var _has_any_spd_changed: bool


func _init(player_side: BattlefieldSide, enemy_side: BattlefieldSide) -> void:
	_player_side = player_side
	_enemy_side = enemy_side


func on_battle_started() -> void:
	if _player_side == null or _enemy_side == null:
		Log.d("Parties are null. Skipping updating turns.")
		return
	
	_curr_idx = -1
	_has_any_spd_changed = false
	_observe_spd_buffs(_player_side)
	_observe_spd_buffs(_enemy_side)
	_update_turns()


func on_battle_ended() -> void:
	_stop_observing_spd_buffs(_player_side)
	_stop_observing_spd_buffs(_enemy_side)


func on_turn_ended() -> void:
	if _has_any_spd_changed:
		_has_any_spd_changed = false
		_update_turns()


func get_next_turn() -> Turn:
	var turn: Turn = null
	if _player_side == null or _enemy_side == null:
		Log.d("Parties not set. Skipping deciding next turn.")
		return turn
	if _player_side.is_party_defeated() and _enemy_side.is_party_defeated():
		Log.d("Everyone is defeated. Skipping deciding next turn.")
		return turn
	if _turns.is_empty():
		Log.e("Turns array have not been created. This should NOT happen! Skipping deciding next turn.")
		return turn
	
	_curr_idx = wrapi(_curr_idx + 1, 0, _turns.size())
	var pos = _turns[_curr_idx]
	var idx = abs(pos) - 1
	var next_fighter: Fighter = null
	var is_player_party_turn: bool = pos > 0
	if is_player_party_turn:
		next_fighter = _player_side.get_member_at(idx)
	else:
		next_fighter = _enemy_side.get_member_at(idx)
	
	if next_fighter:
		turn = Turn.new(next_fighter, is_player_party_turn)
	return turn


func _update_turns() -> void:
	_turns = []
	
	if _player_side == null or _enemy_side == null:
		Log.d("Parties are null. Skipping updating turns.")
		return
	
	var enemy_party_size: int = _enemy_side.get_members().size()
	var player_party_size: int = _player_side.get_members().size()
	_turns.resize(enemy_party_size + player_party_size)
	var arr_idx: int = -1
	for i: int in enemy_party_size:
		arr_idx += 1
		_turns[arr_idx] = (i + 1) * -1
	for i: int in player_party_size:
		arr_idx += 1
		_turns[arr_idx] = i + 1
	
	_turns.sort_custom(_sort_turn_order)
	Log.d("Turn order updated: ", _turns)


func _sort_turn_order(a_pos: int, b_pos: int) -> bool:
	var a_stats: StatsManager = null
	var b_stats: StatsManager = null
	if a_pos > 0:
		a_stats = _player_side.get_member_at(a_pos - 1).get_stats_manager()
	else:
		a_stats = _enemy_side.get_member_at(abs(a_pos) - 1).get_stats_manager()
	if b_pos > 0:
		b_stats = _player_side.get_member_at(b_pos - 1).get_stats_manager()
	else:
		b_stats = _enemy_side.get_member_at(abs(b_pos) - 1).get_stats_manager()
	var a_spd: int = a_stats.get_spd()
	var b_spd: int = b_stats.get_spd()
	if a_spd == b_spd:
		return a_pos > 0
	return a_spd > b_spd


func _observe_spd_buffs(side: BattlefieldSide) -> void:
	for member: Fighter in side.get_members():
		if not member.is_removed_from_battle():
			Utils.safe_connect(
					member.get_stats_manager().spd_buffed, _on_fighter_spd_buffed)


func _stop_observing_spd_buffs(side: BattlefieldSide) -> void:
	for member: Fighter in side.get_members():
		Utils.safe_disconnect(
				member.get_stats_manager().spd_buffed, _on_fighter_spd_buffed)


func _on_fighter_spd_buffed() -> void:
	if !_has_any_spd_changed:
		Log.d("Turn order will update at the end of this turn.")
	_has_any_spd_changed = true


class Turn extends RefCounted:
	var _fighter: Fighter
	var _is_player_party_turn: bool
	
	
	func _init(fighter: Fighter, player_party_turn: bool) -> void:
		_fighter = fighter
		_is_player_party_turn = player_party_turn
	
	
	func get_fighter() -> Fighter:
		return _fighter
	
	
	func is_player_party_turn() -> bool:
		return _is_player_party_turn
