extends Control


signal selected(me)
signal selection_canceled


const ALPHABET: PackedStringArray = [
		"", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

var _enemy_data: BattleEnemyData
var _ocurrence: int
var _curr_hp: int = -1:
	set(value):
		_curr_hp = maxi(-1, _curr_hp - value)
var _curr_mp: int = -1:
	set(value):
		_curr_mp = maxi(-1, _curr_mp - value)

@onready var _status_texture_rect: TextureRect = $StatusTextureRect
@onready var _enemy_texture_rect: TextureRect = $"."
@onready var _damage_label: Label = $DamageLabel
@onready var _name_label: Label = $NameLabel
@onready var _selector_texture_rect: TextureRect = $SelectorTextureRect
@onready var _selector_animation_player: AnimationPlayer = %SelectorAnimationPlayer


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


func get_curr_hp() -> int:
	return _curr_hp


func get_curr_mp() -> int:
	return _curr_mp


func get_full_name() -> String:
	return _name_label.text


func hurt(damage: int) -> int:
	_curr_hp -= damage
	return _curr_hp


func consume_mp(points: int) -> int:
	_curr_mp -= points
	return _curr_mp


## Set ocurrence to 0 or a negative value if this enemy is 
## the only ocurrence of his type on this party.
## Example: In the party there are 1 bug and 2 lizards. For the bug, you should set
## ocurrence to 0 because there is no point in having the postfix " A" on his name
## since it is the only bug in the party.
func set_enemy_data(enemy_data: BattleEnemyData, ocurrence: int) -> void:
	_enemy_data = enemy_data
	_ocurrence = ocurrence
	_setup()


func _setup() -> void:
	if not is_node_ready():
		return
	
	_curr_hp = -1
	_curr_mp = -1
	_enemy_texture_rect.texture = null
	_status_texture_rect.texture = null
	_damage_label.text = ""
	_name_label.text = ""
	
	if _enemy_data == null:
		return
	
	_enemy_texture_rect.texture = _enemy_data.get_texture()
	_curr_hp = _enemy_data.get_initial_hp()
	_curr_mp = _enemy_data.get_initial_mp()
	
	var enemy_name: String = _enemy_data.get_enemy_name()
	var alphabet_idx: int = clampi(_ocurrence, 0, ALPHABET.size() - 1)
	_name_label.text = " ".join([enemy_name, ALPHABET[alphabet_idx]]).trim_suffix(" ")


func _on_focus_entered() -> void:
	_selector_texture_rect.show()
	_selector_animation_player.play("focus")
	_name_label.show()


func _on_focus_exited() -> void:
	_selector_animation_player.stop()
	_selector_texture_rect.hide()
	_name_label.hide()
