@tool
extends CanvasLayer

signal battle_finished(success: bool)

const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")

@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _player_char_container: PanelContainer = %PlayerCharContainer
@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var _battle_narration_box: BattleNarrationBox = %BattleNarrationBox
@onready var _timer: Timer = $Timer


func _ready() -> void:
	if not Engine.is_editor_hint():
		_panel_container.visible = get_parent() == $/root
	_on_preview_set()


func start() -> void: # args: enemy_party
	await TransitionPlayer.play_battle()
	_timer.start(1.0)
	await _timer.timeout
	_panel_container.show()
	_battle_narration_box.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	await TransitionPlayer.play_battle_backwards()
	_timer.start(1.0)
	await _timer.timeout


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview
