extends VBoxContainer


signal current_option_changed(info_msg: String)

const CommandEat = preload("res://resources/instances/day_ex/actions/command_eat.tres")
const CommandCure = preload("res://resources/instances/day_ex/actions/command_cure.tres")

enum Command {
	ATTACK,
	ABILITY,
	EAT,
	CURE,
	FLEE,
}

var _commands: Array[Dictionary] = [
	{
		"label": "RPG_BATTLE_COMMAND_ATTACK",
		"value": { 
			"command": Command.ATTACK,
			"info": "RPG_BATTLE_INFO_COMMAND_ATTACK" 
		},
	},
	{
		"label": "RPG_BATTLE_COMMAND_ABILITY",
		"value": { 
			"command": Command.ABILITY,
			"info": "RPG_BATTLE_INFO_COMMAND_ABILITY" 
		},
	},
	{
		"label": CommandEat.get_action_name(),
		"value": { 
			"command": Command.EAT,
			"info": CommandEat.get_info(),
			"action": CommandEat,
		},
	},
	{
		"label": CommandCure.get_action_name(),
		"value": { 
			"command": Command.EAT,
			"info": CommandCure.get_info(),
			"action": CommandCure,
		},
	},
	{
		"label": "RPG_BATTLE_COMMAND_FLEE",
		"value": { 
			"command": Command.FLEE,
			"info": "RPG_BATTLE_INFO_COMMAND_FLEE",
		},
	}
]

@onready var _command_selector: HSelector = $CommandHSelector
@onready var _action_selector: HSelector = $ActionHSelector


func _ready() -> void:
	_action_selector.text_color.a = 0.0
	_command_selector.set_options(_commands)
	_command_selector.call_deferred("grab_focus")
	# Defferring call to give siblings a chance to be ready
	call_deferred("_on_command_h_selector_current_option_index_changed", _command_selector.current_option_idx)


func _on_command_h_selector_selected(selected: Dictionary) -> void:
	match selected.command:
		Command.ATTACK:
			# TODO Populate action selector possible attacks
			_action_selector.call_deferred("grab_focus")
			_action_selector.text_color.a = 1.0
			print("ATTACK")
		Command.ABILITY:
			# TODO Populate action selector possible abilities
			_action_selector.call_deferred("grab_focus")
			_action_selector.text_color.a = 1.0
			print("ABILITY")
		Command.EAT:
			# TODO Try eating an enemy
			print("EAT")
		Command.CURE:
			print("CURE")
		Command.FLEE:
			# TODO Attempt fleeing
			print("FLEE")


func _on_command_h_selector_current_option_index_changed(index: int) -> void:
	current_option_changed.emit(_commands[index].value.info)


func _on_action_h_selector_current_option_index_changed(index: int) -> void:
	# TODO Change info label text with this ability description
	pass


func _on_action_h_selector_selected(value: Variant) -> void:
	# TODO Execute selected ability
	pass # Replace with function body.


func _on_focus_entered() -> void:
	_command_selector.call_deferred("grab_focus")
