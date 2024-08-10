extends TextureRect

# FIXME set_path: Another resource is loaded from path 'res://scenes/day_ex/game/fighter.tscn' (possible cyclic resource inclusion).
# FIXME _parse_ext_resource: res://scenes/day_ex/game/fighter.tscn:561 - Parse Error: [ext_resource] referenced non-existent resource at: res://scenes/day_ex/game/fighter.gd

signal selected(me)
signal selection_canceled
signal scraps_qty_changed

enum CauseOfDeath {
	UNSPECIFIED,
	POISONED,
	MURDER,
	EATEN,
}

const BattlefieldSide = preload("res://scenes/day_ex/game/battlefield_side.gd")
const ActionAnimation = preload("res://scenes/day_ex/game/action_animation.gd")
const StatusDisplayManager = preload("res://scenes/day_ex/game/status_display_manager.gd")
const StatusDisplay = preload("res://scenes/day_ex/game/status_display.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

var DEFAULT_FIGHTER_BRAIN: FighterBrain = DefaultFighterBrain.new()
const ALPHABET: PackedStringArray = [
		"", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

var scraps: int:
	set(value):
		var old_val: int = scraps
		scraps = clampi(value, 0, 9)
		if scraps != old_val:
			scraps_qty_changed.emit()

var _stats_manager := StatsManager.new()
var _status_manager := StatusManager.new()
var _fighter_data: FighterData
var _cause_of_death: CauseOfDeath
var _has_fled: bool
var _ocurrence: int
var _installed_brain: FighterBrain

@onready var _damage_label: Label = $DamageLabel
@onready var _name_label: Label = $NameLabel
@onready var _selector_texture_rect: TextureRect = $SelectorTextureRect
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _action_animation: ActionAnimation = $ActionAnimation
@onready var _status_display_manager: StatusDisplayManager = $StatusDisplayManager
@onready var _status_display: StatusDisplay = $StatusDisplay


func _ready() -> void:
	_status_display_manager.setup(_stats_manager, _status_manager)
	_setup()


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		accept_event()
		release_focus()
		selected.emit(self)
	if event.is_action_pressed("ui_cancel"):
		accept_event()
		release_focus()
		selection_canceled.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_fighter_name_label()


## Set ocurrence to 0 or a negative value if this fighter is 
## the only one of their type on this party.
## Example: In the party there are 1 bug and 2 lizards. For the bug, you should set
## ocurrence to 0 because there is no point in having the postfix " A"
## on their name since they are the only bug in the party.
func set_fighter_data(fighter_data: FighterData, ocurrence: int = 0) -> void:
	_fighter_data = fighter_data
	_ocurrence = ocurrence
	_setup()


func install_brain(brain: FighterBrain) -> void:
	_installed_brain = brain


func get_full_name() -> String:
	return _name_label.text


func get_stats_manager() -> StatsManager:
	return _stats_manager


func get_status_display_manager() -> StatusDisplayManager:
	return _status_display_manager


func is_removed_from_battle() -> bool:
	return is_dead() or has_fled()


func is_dead() -> bool:
	return _stats_manager.get_curr_hp() <= 0


func has_fled() -> bool:
	return _has_fled


func is_eaten() -> bool:
	return is_dead() and _cause_of_death == CauseOfDeath.EATEN


func get_scraps_granted() -> int:
	return _fighter_data.get_loot_scraps() if _fighter_data else 0


func get_exp_granted() -> int:
	return _fighter_data.get_loot_exp() if _fighter_data else 0


func get_weighted_actions() -> Array[EnemyCommand]:
	return _fighter_data.get_actions() if _fighter_data else []


func get_actions() -> Array[BattleAction]:
	var available_weighted_actions: Array[EnemyCommand] = \
			get_weighted_actions()
	var actions_count: int = available_weighted_actions.size()
	
	var actions: Array[BattleAction] = []
	actions.resize(actions_count)
	for i: int in actions_count:
		actions[i] = available_weighted_actions[i].get_action()
	return actions


func wait_flee() -> void:
	if not is_removed_from_battle():
		_has_fled = true
		_animation_player.play(&"flee")
		await _animation_player.animation_finished
		self_modulate.a = 0
		_stats_manager.reset_buffs()
		_status_manager.clear_all_status_effect()
		print(get_full_name(), " fled.")


func enter_battlefield() -> void:
	if is_dead() or not has_fled():
		return
	
	_has_fled = false
	_animation_player.play(&"RESET")
	_stats_manager.reset_buffs()
	_status_manager.clear_all_status_effect()


func take_turn(ally_side: BattlefieldSide, foe_side: BattlefieldSide, 
		is_flee_forbidden: bool) -> void:
	if is_removed_from_battle():
		print("WARN: %s is not in the battle field. Skipping their turn." % get_full_name())
		return
	
	await _on_turn_started()
	_animation_player.play(&"take_turn")
	await _animation_player.animation_finished
	var brain: FighterBrain = _get_active_brain() 
	var command_completed: bool = false
	while not command_completed:
		brain.start_command_selection(self)
		var command: BattleCommand = await brain.command_selected
		if command is BattleCommand.Pass:
			command_completed = await _run_pass_command()
		elif command is BattleCommand.Flee:
			command_completed = \
					await _run_flee_command(ally_side, is_flee_forbidden)
		elif command is BattleCommand.Hurt:
			var hurt_command := command as BattleCommand.Hurt
			command_completed = await _run_attack_command(
					brain, hurt_command, ally_side, foe_side)
		else:
			print("Unknown battle command class. Skipping turn.")
			command_completed = await _run_pass_command()
	await _on_turn_finished()


## Can be awaited
func get_hurt(attacker: Fighter, attack: BattleAction) -> void:
	if is_removed_from_battle():
		return
	
	_action_animation.configure(attack)
	_action_animation.play()
	await _action_animation.finished
	
	if attack.is_physical_attack():
		await _hurt_with_phys_attack(attacker, attack)
		
		if is_dead():
			var is_devoured: bool = attack.is_devour_attack()
			var cause_of_death = \
					CauseOfDeath.EATEN if is_devoured else CauseOfDeath.MURDER
			await _on_death(cause_of_death)
			return
	
	if attack.inflicts_any_status_effect():
		await _hurt_with_status_attack(attack)
	print("%s HP: %s" % [get_full_name(), get_stats_manager().get_curr_hp()])


func _get_active_brain() -> FighterBrain:
	return _installed_brain if _installed_brain else DEFAULT_FIGHTER_BRAIN


func _get_target_side(attack: BattleAction, ally_side: BattlefieldSide,
		foe_side: BattlefieldSide) -> BattlefieldSide:
	var is_charmed: bool = _status_manager.is_charmed()
	var target_side: BattlefieldSide
	var target_self: bool = attack.is_target_self()
	if is_charmed:
		target_side = foe_side if attack.is_target_self() else ally_side
	else:
		target_side = ally_side if attack.is_target_self() else foe_side
	return target_side


func _on_turn_started() -> void:
	if is_removed_from_battle():
		return
	
	if randi() % 101 <= _stats_manager.get_lck():
		_stats_manager.reset_buffs()
		# TODO Send stats reset (buff debuff reset) event
	if randi() % 100 <= _stats_manager.get_lck():
		_status_manager.clear_all_status_effect()
		# TODO Send illness cleared event


## Can be awaited
func _on_turn_finished() -> void:
	# TODO DO not apply poison damage when battle is finished
	if is_removed_from_battle() or not _status_manager.is_poisoned():
		return
	
	_stats_manager.decrease_hp(_status_manager.get_poison_damage())
	_animation_player.play(&"hurt")
	await _animation_player.animation_finished
	# TODO send the hurt by poison signal
	
	if is_dead():
		_on_death(CauseOfDeath.POISONED)


func _hurt_with_phys_attack(attacker: Fighter, attack: BattleAction) -> void:
	if randi() % attack.get_hit_chance_percent() <= _stats_manager.get_agi():
		_animation_player.play(&"evade")
		await _animation_player.animation_finished
		# TODO Send evasion signal
		return
	
	var damage: int = attack.calculate_hp_damage(
			attacker.get_stats_manager(), _stats_manager)
	_stats_manager.decrease_hp(damage)
	_damage_label.text = str(absi(damage))
	if damage > 0:
		_animation_player.play(
				&"being_eaten" if attack.is_devour_attack() else &"hurt")
		await _animation_player.animation_finished
		# TODO send the hurt signal
	elif damage < 0:
		_animation_player.play(&"cure")
		await _animation_player.animation_finished
		# TODO send the cured signal


func _hurt_with_status_attack(attack: BattleAction) -> void:
	var inflict_status: bool = \
			randi() % attack.get_hit_chance_percent() <= _stats_manager.get_lck()
	if inflict_status:
		# TODO Send afflicted event?
		_apply_buffs(attack)
		_apply_illness(attack)
	elif not attack.is_physical_attack():
		_animation_player.play(&"evade")
		await _animation_player.animation_finished
		# TODO Send evasion signal


func _apply_buffs(attack: BattleAction) -> void:
	_stats_manager.buff_atk(attack.get_status_effect_attack())
	_stats_manager.buff_def(attack.get_status_effect_defense())
	_stats_manager.buff_speed(attack.get_status_effect_speed())


func _apply_illness(attack: BattleAction) -> void:
	if attack.inflicts_poison():
		_status_manager.set_poison_damage(attack.get_poison_damage())
		# TODO Send poisoned event
	if attack.inflicts_love():
		_status_manager.set_is_charmed(true)
		# TODO Send charmed event


func _setup() -> void:
	if not is_node_ready():
		return
	
	texture = null
	_damage_label.text = ""
	_name_label.text = ""
	_cause_of_death = CauseOfDeath.UNSPECIFIED
	_has_fled = false
	self_modulate.a = 1.0
	_animation_player.play(&"RESET")
	focus_mode = Control.FOCUS_ALL
	
	if _fighter_data == null:
		return
	
	texture = _fighter_data.get_texture()
	_update_fighter_name_label()
	_stats_manager.setup(_fighter_data)


func _update_fighter_name_label() -> void:
	if not _fighter_data or not is_node_ready():
		return
	
	var fighter_name: String = tr(_fighter_data.get_char_name())
	var alphabet_idx: int = clampi(_ocurrence, 0, ALPHABET.size() - 1)
	var pos_letter: String = ALPHABET[alphabet_idx]
	_name_label.text = " ".join([fighter_name, pos_letter]).trim_suffix(" ")


func _run_pass_command() -> bool:
	# TODO Narrate turn passed
	# TODO Create pass animation?
	print(get_full_name(), " passed their turn.")
	return true


func _run_flee_command(ally_side: BattlefieldSide, 
		is_flee_forbidden: bool) -> bool:
	# TODO Narrate trying to flee
	var successful_flee_attempt: bool = not is_flee_forbidden and \
			 randi() % 101 <= _stats_manager.get_lck()
	if successful_flee_attempt:
		for fighter: Fighter in ally_side.get_members():
			await fighter.wait_flee()
		# TODO Narrate party fled
	else:
		# TODO Narrate could not flee
		pass
	return true


func _run_attack_command(brain: FighterBrain, command: BattleCommand.Hurt, 
		ally_side: BattlefieldSide, foe_side: BattlefieldSide) -> bool:
	var attack: BattleAction = command.get_action()
	if not _have_enough_resources_for(attack):
		await _narrate_not_enough_resources(attack)
		return false
	
	var target_side: BattlefieldSide = \
			_get_target_side(attack, ally_side, foe_side)
	brain.start_target_selection(target_side)
	var target: Fighter = await brain.target_selected
	if target and not target.is_removed_from_battle():
		_consume_resource(attack)
		_animation_player.play(&"attack")
		await _animation_player.animation_finished
		# TODO narrate attack and target
		await target.get_hurt(self, attack)
		return true
	return false


func _have_enough_resources_for(attack: BattleAction) -> bool:
	var cost: int = attack.get_cost()
	match attack.get_consumable():
		BattleAction.Consumable.MP:
			if _stats_manager.get_curr_mp() < cost:
				return false
		BattleAction.Consumable.SCRAPS:
			if scraps < cost:
				return false
	return true


func _narrate_not_enough_resources(attack: BattleAction) -> void:
	pass


func _consume_resource(attack: BattleAction) -> bool:
	var cost: int = attack.get_cost()
	match attack.get_consumable():
		BattleAction.Consumable.MP:
			_stats_manager.decrease_mp(cost)
			print(get_full_name(), " MP: ", _stats_manager.get_curr_mp())
			return true
		BattleAction.Consumable.SCRAPS:
			scraps -= cost
			return true
	return true


func _on_death(cause_of_death: CauseOfDeath = CauseOfDeath.UNSPECIFIED) -> void:
	_cause_of_death = cause_of_death
	_animation_player.play(
			&"eaten" if cause_of_death == CauseOfDeath.EATEN else &"die")
	# TODO Send devoured/dead event
	await _animation_player.animation_finished
	focus_mode = Control.FOCUS_NONE
	self_modulate.a = 0.0
	_stats_manager.reset_buffs()
	_status_manager.clear_all_status_effect()


func _on_focus_entered() -> void:
	_selector_texture_rect.show()
	_animation_player.play(&"focus")
	_name_label.show()


func _on_focus_exited() -> void:
	_animation_player.stop()
	_selector_texture_rect.hide()
	_name_label.hide()


func _on_status_display_manager_displayed_status_changed(
			new_status: StatusDisplayManager.Status) -> void:
	_status_display.display_status(new_status)
