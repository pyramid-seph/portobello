extends Node

const STORY_MODE_OPTIONS := [
	{
		"label": "1",
		"value": Game.Minigame.STORY_DAY_01,
	},
	{
		"label": "2",
		"value": Game.Minigame.STORY_DAY_02,
	},
	{
		"label": "3",
		"value": Game.Minigame.STORY_DAY_03,
	},
	{
		"label": "EX",
		"value": Game.Minigame.STORY_EXTRA,
	},
]

const SCORE_ATTACK_MODE_OPTIONS := [
	{
		"label": "Día 1A",
		"value": Game.Minigame.SCORE_ATTACK_1A,
	},
	{
		"label": "Día 1B",
		"value": Game.Minigame.SCORE_ATTACK_1B,
	},
	{
		"label": "Día 1C",
		"value": Game.Minigame.SCORE_ATTACK_1C,
	},
	{
		"label": "Día 1D",
		"value": Game.Minigame.SCORE_ATTACK_1D,
	},
	{
		"label": "Día 2",
		"value": Game.Minigame.SCORE_ATTACK_2,
	},
	{
		"label": "Día 3A",
		"value": Game.Minigame.SCORE_ATTACK_3A,
	},
	{
		"label": "Día 3B",
		"value": Game.Minigame.SCORE_ATTACK_3B,
	},
]

@export_group("Debug", "_debug")
@export var _debug_is_cold_boot: bool = false:
	get:
		return _debug_is_cold_boot and OS.is_debug_build()

@onready var _title_screen = $TitleScreen
@onready var _logos_roll := $LogosRoll
@onready var _story_mode_game_selector := %StoryModeGameSelector
@onready var _score_attack_game_selector := %ScoreAttackGameSelector
@onready var _exit_game_btn = %ExitGameBtn
@onready var _confirm_exit_dialog = $ConfirmExitDialog
@onready var _progress_menu = %ProgressMenu
@onready var _main_menu = %MainMenu
@onready var _game_title = %GameTitle
@onready var _show_scores_button := %ShowScoresBtn


func _ready() -> void:
	if Game.is_cold_boot or _debug_is_cold_boot:
		Game.is_cold_boot = false
		_enable_title_screen(false)
		_logos_roll.start()
	else:
		_enable_title_screen(true)


func _set_day_options() -> void:
	_story_mode_game_selector.options.clear()
	_story_mode_game_selector.options.append_array(STORY_MODE_OPTIONS)


func _set_score_attack_options() -> void:
	_score_attack_game_selector.options.clear()
	_score_attack_game_selector.options.append_array(SCORE_ATTACK_MODE_OPTIONS)


func _enable_title_screen(value: bool) -> void:
	_title_screen.visible = value
	if not value:
		_title_screen.process_mode = Node.PROCESS_MODE_DISABLED 
	else:
		_set_day_options()
		_set_score_attack_options()
		_title_screen.process_mode = Node.PROCESS_MODE_ALWAYS
		_story_mode_game_selector.call_deferred("grab_focus")


func _on_logos_roll_rolled() -> void:
	_logos_roll.visible = false
	_enable_title_screen(true)


func _on_minigame_selected(value) -> void:
	Game.start(value)


func _on_show_scores_btn_pressed() -> void:
	_main_menu.visible = false
	_game_title.visible = false
	_progress_menu.visible = true


func _on_show_options_btn_pressed() -> void:
	pass # Replace with function body.


func _on_exit_game_btn_pressed() -> void:
	_confirm_exit_dialog.visible = true


func _on_confirm_exit_dialog_negative_btn_pressed() -> void:
	_exit_game_btn.call_deferred("grab_focus")


func _on_confirm_exit_dialog_positive_btn_pressed() -> void:
	get_tree().quit()


func _on_progress_menu_closed() -> void:
	_main_menu.visible = true
	_game_title.visible = true
	_show_scores_button.call_deferred("grab_focus")
