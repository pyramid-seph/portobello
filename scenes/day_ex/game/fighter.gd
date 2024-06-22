extends Control


signal selected(me)
signal selection_canceled

const ActionAnimation = preload("res://scenes/day_ex/game/action_animation.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const StatusManager = preload("res://scenes/day_ex/game/status_manager.gd")
const StatsManager = preload("res://scenes/day_ex/game/stats_manager.gd")

const ALPHABET: PackedStringArray = [
		"", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

var _curr_level: int = 1
var _fighter_data: FighterData
var _ocurrence: int
var _curr_hp: int:
	set(value):
		var max_hp: int = _stats_manager.get_max_hp() if _fighter_data else 1
		_curr_hp = clampi(value, 0, max_hp)
var _curr_mp: int:
	set(value):
		var max_mp: int = _stats_manager.get_max_mp() if _fighter_data else 1
		_curr_mp = clampi(value, 0, max_mp)
var _is_dead: bool

@onready var _status_manager: StatusManager = $StatusManager
@onready var _fighter_texture_rect: TextureRect = $"."
@onready var _damage_label: Label = $DamageLabel
@onready var _name_label: Label = $NameLabel
@onready var _selector_texture_rect: TextureRect = $SelectorTextureRect
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _action_animation: ActionAnimation = $ActionAnimation
@onready var _stats_manager: StatsManager = $StatsManager


func _ready() -> void:
	_setup()


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


func get_curr_hp() -> int:
	return _curr_hp


func get_curr_mp() -> int:
	return _curr_mp


func get_full_name() -> String:
	return _name_label.text


func get_stats_manager() -> StatsManager:
	return _stats_manager


## Can be awaited
func receive_attack(attacker: Fighter, attack: BattleAction) -> void:
	if _is_dead:
		return
	
	_action_animation.configure(attack)
	_action_animation.play()
	await _action_animation.finished
	
	if randi() % attack.get_hit_chance_percent() <= _fighter_data.get_agility():
		_animation_player.play("evade")
		await _animation_player.animation_finished
		# TODO Send evasion signal
		return
	
	var damage: int = attack.calculate_hp_damage(attacker, self)
	var is_status_inflicted: bool = attack.inflict_status(attacker, self)
	
	_curr_hp -= damage
	_damage_label.text = str(absi(damage))
	# TODO Manage status effects
	# TODO Play a different animation when char is eaten
	if damage > 0:
		_animation_player.play("hurt")
		await _animation_player.animation_finished
		# TODO send the hurt signal
	elif damage < 0:
		_animation_player.play("cure")
		await _animation_player.animation_finished
		# TODO send the cured signal
	
	_is_dead = _curr_hp <= 0
	if _is_dead:
		_animation_player.play("die")
		await _animation_player.animation_finished
		focus_mode = Control.FOCUS_NONE

func take_turn() -> void:
	_animation_player.play(&"take_turn")
	await _animation_player.animation_finished


func on_turn_finished() -> void:
	# TODO Apply post turn damage
	pass


func is_dead() -> bool:
	return _is_dead


func consume_mp(points: int) -> int:
	_curr_mp -= points
	return _curr_mp


## Set ocurrence to 0 or a negative value if this fighter is 
## the only one of their type on this party.
## Example: In the party there are 1 bug and 2 lizards. For the bug, you should set
## ocurrence to 0 because there is no point in having the postfix " A"
## on their name since they are the only bug in the party.
func set_fighter_data(fighter_data: FighterData, ocurrence: int = 0) -> void:
	_fighter_data = fighter_data
	_ocurrence = ocurrence
	_setup()


func _setup(level: int = 1) -> void:
	if not is_node_ready():
		return
	
	_curr_level = level
	_curr_hp = 0
	_curr_mp = 0
	_fighter_texture_rect.texture = null
	_damage_label.text = ""
	_name_label.text = ""
	
	if _fighter_data == null:
		return
	
	_fighter_texture_rect.texture = _fighter_data.get_texture()
	_curr_hp = _stats_manager.get_max_hp()
	_curr_mp = _stats_manager.get_max_mp()
	
	_update_fighter_name_label()


func _update_fighter_name_label() -> void:
	if not _fighter_data or not is_node_ready():
		return
	
	var fighter_name: String = tr(_fighter_data.get_char_name())
	var alphabet_idx: int = clampi(_ocurrence, 0, ALPHABET.size() - 1)
	var pos_letter: String = ALPHABET[alphabet_idx]
	_name_label.text = " ".join([fighter_name, pos_letter]).trim_suffix(" ")


func _on_focus_entered() -> void:
	_selector_texture_rect.show()
	_animation_player.play(&"focus")
	_name_label.show()


func _on_focus_exited() -> void:
	_animation_player.stop()
	_selector_texture_rect.hide()
	_name_label.hide()
