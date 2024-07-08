extends TextureRect


signal selected(me)
signal selection_canceled
signal displayed_status_changed(new_status: StatusDisplayManager.Status)

const ActionAnimation = preload("res://scenes/day_ex/game/action_animation.gd")
const StatusDisplayManager = preload("res://scenes/day_ex/game/status_display_manager.gd")
const StatusDisplay = preload("res://scenes/day_ex/game/status_display.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")

const ALPHABET: PackedStringArray = [
		"", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

var _refresh_status_display: bool
var _stats_manager := StatsManager.new()
var _status_manager := StatusManager.new()
var _fighter_data: FighterData
var _ocurrence: int

@onready var _damage_label: Label = $DamageLabel
@onready var _name_label: Label = $NameLabel
@onready var _selector_texture_rect: TextureRect = $SelectorTextureRect
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _action_animation: ActionAnimation = $ActionAnimation
@onready var _status_display_manager: StatusDisplayManager = $StatusDisplayManager
@onready var _status_display: StatusDisplay = $StatusDisplay


func _ready() -> void:
	_setup()


func _process(_delta: float) -> void:
	if not _fighter_data or is_dead():
		return
	
	if _refresh_status_display:
		_refresh_status_display = false
		_status_display_manager.update_status(_stats_manager, _status_manager)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
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


func get_full_name() -> String:
	return _name_label.text


func get_stats_manager() -> StatsManager:
	return _stats_manager


func is_dead() -> bool:
	return _stats_manager.get_curr_hp() <= 0


## Can be awaited
func take_turn() -> void:
	await _on_turn_started()
	_animation_player.play(&"take_turn")
	await _animation_player.animation_finished
	# TODO Pick action.
	# TODO Pick target.
	# TODO Execute action.
	await _on_turn_finished()


func _on_turn_started() -> void:
	if is_dead():
		return
	
	if randi() % 101 <= _stats_manager.get_lck():
		_stats_manager.reset_buffs()
		# TODO Send stats reset (buff debuff reset) event
	if randi() % 100 <= _stats_manager.get_lck():
		_status_manager.clear_all_status_effect()
		# TODO Send illness cleared event


## Can be awaited
func _on_turn_finished() -> void:
	if is_dead() or not _status_manager.is_poisoned():
		return
	
	_stats_manager.decrease_hp(_status_manager.get_poison_damage())
	_animation_player.play(&"hurt")
	await _animation_player.animation_finished
	# TODO send the hurt by poison signal
	
	if is_dead():
		_animation_player.play(&"die")
		await _animation_player.animation_finished
		focus_mode = Control.FOCUS_NONE
		_stats_manager.reset_buffs()
		_status_manager.clear_all_status_effect()
		hide()


## Can be awaited
func get_hurt(attacker: Fighter, attack: BattleAction) -> void:
	if is_dead():
		return
	
	_action_animation.configure(attack)
	_action_animation.play()
	await _action_animation.finished
	
	if attack.is_physical_attack():
		await _hurt_with_phys_attack(attacker, attack)
		
		if is_dead():
			var is_devoured: bool = attack.is_devour_attack()
			_animation_player.play(&"eaten" if is_devoured else &"die")
			# TODO Send devoured/dead event
			await _animation_player.animation_finished
			focus_mode = Control.FOCUS_NONE
			_stats_manager.reset_buffs()
			_status_manager.clear_all_status_effect()
			hide()
			return
	
	if attack.inflicts_any_status_effect():
		await _hurt_with_status_attack(attack)


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
		_animation_player.play(&"hurt")
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
	_refresh_status_display = true
	
	if _fighter_data == null:
		return
	
	texture = _fighter_data.get_texture()
	
	_update_fighter_name_label()
	_stats_manager.setup(_fighter_data)
	Utils.safe_connect(_stats_manager.buffed, _on_status_or_stats_changed)
	Utils.safe_connect(_status_manager.status_changed, _on_status_or_stats_changed)


func _update_fighter_name_label() -> void:
	if not _fighter_data or not is_node_ready():
		return
	
	var fighter_name: String = tr(_fighter_data.get_char_name())
	var alphabet_idx: int = clampi(_ocurrence, 0, ALPHABET.size() - 1)
	var pos_letter: String = ALPHABET[alphabet_idx]
	_name_label.text = " ".join([fighter_name, pos_letter]).trim_suffix(" ")


func _on_status_or_stats_changed() -> void:
	_refresh_status_display = true


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
	print(get_full_name(), " > Status: ", new_status)
	_status_display.display_status(new_status)
	displayed_status_changed.emit(new_status)
