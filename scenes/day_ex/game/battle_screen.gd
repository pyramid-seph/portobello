@tool
extends CanvasLayer

signal battle_finished(success: bool)

const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const RpgEnemy = preload("res://scenes/day_ex/game/rpg_enemy.gd")
const EnemyPartyContainer = preload("res://scenes/day_ex/game/enemy_party_container.gd")

const EnemyScene = preload("res://scenes/day_ex/game/rpg_enemy.tscn")

@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _battle_narration_box: BattleNarrationBox = %BattleNarrationBox
@onready var _enemy_party_container: EnemyPartyContainer = %EnemyPartyContainer
@onready var _player_char: TextureRect = %PlayerChar
@onready var _player_commands_group_visibility: GroupVisibility = %PlayerCommandsGroupVisibility
@onready var _timer: Timer = $Timer


func _ready() -> void:
	if not Engine.is_editor_hint():
		_panel_container.visible = get_parent() == $/root
		_enemy_party_container.enemy_slected.connect(func(_a): _exit_battle_screen())
	_on_preview_set()


func start(enemy_party: BattleParty, background: Texture2D) -> void:
	_enter_battle_screen(enemy_party, background)
	_timer.start(1)
	await _timer.timeout
	_enemy_party_container.call_deferred("grab_focus")


func _enter_battle_screen(enemy_party: BattleParty, background: Texture2D) -> void:
	await TransitionPlayer.play_battle()
	_enemy_party_container.setup(enemy_party, background)
	_panel_container.show()
	_battle_narration_box.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	await TransitionPlayer.play_battle_backwards()


func _exit_battle_screen() -> void:
	await TransitionPlayer.play_battle()
	teardown()
	_panel_container.hide()
	await TransitionPlayer.play_battle_backwards()
	battle_finished.emit(true)


func teardown() -> void:
	_enemy_party_container.teardown()


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview
