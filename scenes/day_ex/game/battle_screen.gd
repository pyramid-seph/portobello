@tool
extends CanvasLayer

signal battle_finished(success: bool)

const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const RpgEnemy = preload("res://scenes/day_ex/game/rpg_enemy.gd")

const EnemyScene = preload("res://scenes/day_ex/game/rpg_enemy.tscn")

@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _player_char_container: PanelContainer = %PlayerCharContainer
@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var _battle_narration_box: BattleNarrationBox = %BattleNarrationBox
@onready var _back_row: HBoxContainer = %BackRow
@onready var _front_row: HBoxContainer = %FrontRow
@onready var _timer: Timer = $Timer


func _ready() -> void:
	if not Engine.is_editor_hint():
		_panel_container.visible = get_parent() == $/root
	_on_preview_set()


func start(enemy_party: BattleParty, background: Texture2D) -> void:
	await TransitionPlayer.play_battle()
	_timer.start(1.0)
	await _timer.timeout
	setup(enemy_party, background)
	_panel_container.show()
	_battle_narration_box.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	await TransitionPlayer.play_battle_backwards()
	_timer.start(1.0)


func setup(enemy_party: BattleParty, background: Texture2D) -> void:
	setup_screen(enemy_party, background)


func setup_screen(enemy_party: BattleParty, background: Texture2D) -> void:
	_background_texture_rect.texture = background
	
	for child_node: Node in _front_row.get_children():
		child_node.queue_free()
	
	for child_node: Node in _back_row.get_children():
		child_node.queue_free()
	
	for enemy_data: BattleEnemyData in enemy_party.get_front_row_enemies():
		var new_enemy_node: RpgEnemy = EnemyScene.instantiate()
		new_enemy_node.enemy_data = enemy_data
		_front_row.add_child(new_enemy_node)
	
	for enemy_data: BattleEnemyData in enemy_party.get_back_row_enemies():
		var new_enemy_node: RpgEnemy = EnemyScene.instantiate()
		new_enemy_node.enemy_data = enemy_data
		_back_row.add_child(new_enemy_node)


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview
