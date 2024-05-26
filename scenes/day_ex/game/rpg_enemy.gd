extends Node


@export var enemy_data: BattleEnemyData:
	set(value):
		enemy_data = value
		_on_enemy_data_set()

@onready var _status_texture_rect: TextureRect = $StatusTextureRect
@onready var _enemy_texture_rect: TextureRect = $"."
@onready var _damage_label: Label = $DamageLabel
@onready var _selector_texture_rect: TextureRect = $SelectorTextureRect


var _curr_hp: int = -1:
	set(value):
		_curr_hp = maxi(-1, _curr_hp - value)
var _curr_mp: int = -1:
	set(value):
		_curr_mp = maxi(-1, _curr_mp - value)


func _ready() -> void:
	_on_enemy_data_set()


func get_curr_hp() -> int:
	return _curr_hp


func get_curr_mp() -> int:
	return _curr_mp


func hurt(damage: int) -> int:
	_curr_hp -= damage
	return _curr_hp


func consume_mp(points: int) -> int:
	_curr_mp -= points
	return _curr_mp


func _on_enemy_data_set() -> void:
	if not is_node_ready():
		return
	
	reset()
	
	if enemy_data == null:
		return
	
	_enemy_texture_rect.texture = enemy_data.get_texture()
	_curr_hp = enemy_data.get_initial_hp()
	_curr_mp = enemy_data.get_initial_mp()


func reset() -> void:
	_curr_hp = -1
	_curr_mp = -1
	_enemy_texture_rect.texture = null
	_status_texture_rect.texture = null
	_damage_label.text = ""
