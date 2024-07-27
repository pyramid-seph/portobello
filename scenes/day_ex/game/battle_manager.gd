class_name BattleManager
extends RefCounted


const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const BattlefieldSide = preload("res://scenes/day_ex/game/battlefield_side.gd")

var _player_side: BattlefieldSide
var _enemy_side: BattlefieldSide
var _turn_order_manager: TurnOrderManager


func _init(player_side: BattlefieldSide, enemy_side: BattlefieldSide) -> void:
	_player_side = player_side
	_enemy_side = enemy_side
	_turn_order_manager = TurnOrderManager.new(player_side, enemy_side)


func start_battle() -> Result:
	_on_battle_started()
	await _battle_loop()
	_on_battle_ended()
	return _build_battle_result()


func _on_battle_started() -> void:
	_turn_order_manager.on_battle_started()


func _on_battle_ended() -> void:
	_turn_order_manager.on_battle_ended()


func _battle_loop() -> void:
	while not _can_battle_continue():
		_turn_order_manager.on_turn_started()
		
		var turn: TurnOrderManager.Turn = _turn_order_manager.get_next_turn()
		if not turn:
			_turn_order_manager.on_turn_ended()
			print("Next turn is null. This should NOT happen. Cancelling battle!")
			break
		
		var next_fighter: Fighter = turn.get_fighter()
		if next_fighter and not next_fighter.is_removed_from_battle():
			var ally_side: BattlefieldSide = null
			var foe_side: BattlefieldSide = null
			if turn.is_player_party_turn():
				ally_side = _player_side
				foe_side = _enemy_side
			else:
				ally_side = _enemy_side
				foe_side = _player_side
			#TODO Divide player turns so we can introduce narration stuff?
			await next_fighter.take_turn(ally_side, foe_side)
		else:
			print("Fighter is removed from battle. Skipping their turn.")
		
		_turn_order_manager.on_turn_ended()


func _can_battle_continue() -> bool:
	var any_party_defeated: bool = _player_side.is_party_defeated() or \
			_enemy_side.is_party_defeated()
	return any_party_defeated


func _build_battle_result() -> Result:
	# FIXME If player fled, game over should NOT be true
	var game_over: bool = _player_side.is_party_defeated()
	var scraps_obtained: int = 0
	var exp_gained: int = 0
	if not game_over:
		for enemy: Fighter in _enemy_side.get_members():
			if enemy.is_eaten():
				scraps_obtained += enemy.get_scraps_granted()
			if enemy.is_dead():
				exp_gained += enemy.get_exp_granted()
	return Result.new(game_over, scraps_obtained, exp_gained)


class Result extends RefCounted:
	var _is_game_over: bool
	var _obtained_scraps: int
	var _exp_gained: int
	
	
	func _init(game_over: bool, obtained_scraps: int, exp_gained: int) -> void:
		_is_game_over = game_over
		_obtained_scraps = obtained_scraps
		_exp_gained = exp_gained
	
	
	func _to_string() -> String:
		return "is_game_over: %s - obtained_scraps: %s - exp_gained: %s" % \
				[_is_game_over, _obtained_scraps, _exp_gained]
	
	
	func is_game_over() -> bool:
		return _is_game_over
	
	
	func get_obtained_scraps() -> int:
		return _obtained_scraps
	
	
	func get_exp_gained() -> int:
		return _exp_gained
