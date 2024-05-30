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
	setup(enemy_party, background)
	_panel_container.show()
	_battle_narration_box.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	await TransitionPlayer.play_battle_backwards()
	
	_timer.start(3.0)
	await _timer.timeout
	
	await TransitionPlayer.play_battle()
	teardown()
	_panel_container.hide()
	await TransitionPlayer.play_battle_backwards()
	battle_finished.emit(true)


func _setup_enemy_row(enemies: Array[BattleEnemyData],
		row: HBoxContainer, 
		tally: Dictionary,
		enemy_ocurrences_count: Dictionary) -> void:
	
	for enemy_data: BattleEnemyData in enemies:
		var new_enemy_node: RpgEnemy = EnemyScene.instantiate()
		
		var enemy_name: String = enemy_data.get_enemy_name()
		if tally.has(enemy_name):
			tally[enemy_name] += 1
		else:
			tally[enemy_name] = 1
		var unique: bool = enemy_ocurrences_count[enemy_name] == 1
		var enemy_ocurrence: int = -1 if unique else tally[enemy_name]
		new_enemy_node.set_enemy_data(enemy_data, enemy_ocurrence)
		
		row.add_child(new_enemy_node)


func setup(enemy_party: BattleParty, background: Texture2D) -> void:
	_background_texture_rect.texture = background
	
	var tally := {}
	var enemy_ocurrences_count = enemy_party.count_enemy_ocurrences()
	_setup_enemy_row(enemy_party.get_front_row_enemies(), 
			_front_row, tally, enemy_ocurrences_count)
	_setup_enemy_row(enemy_party.get_back_row_enemies(),
			 _back_row, tally, enemy_ocurrences_count)


func _clear_enemy_row(row: HBoxContainer) -> void:
	for child_node: Node in row.get_children():
		child_node.queue_free()


func teardown() -> void:
	_background_texture_rect.texture = null
	_clear_enemy_row(_front_row)
	_clear_enemy_row(_back_row)


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview
