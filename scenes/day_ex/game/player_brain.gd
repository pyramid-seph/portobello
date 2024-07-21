extends Node

signal next_move_decided
signal attempt_flee

const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const PartyContainer = preload("res://scenes/day_ex/game/party_container.gd")

@onready var _action_selector: ActionSelector = %ActionSelector



func decide_next_action(enemy_party: PartyContainer) -> NextAction:
	_action_selector.call_deferred("grab_focus")
	
	enemy_party.call_deferred("grab_focus")
	var fighter: Fighter = await enemy_party.target_selected
	
	return NextAction.flee()
