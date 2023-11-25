extends Node

const MenuBgDay01Texture: Texture2D = preload("res://art/menu_screen/menu_bg_day_01.png")
const MenuBgDay02Texture: Texture2D = preload("res://art/menu_screen/menu_bg_day_02.png")
const MenuBgDay03Texture: Texture2D = preload("res://art/menu_screen/menu_bg_day_03.png")
const MenuBgDayExTexture: Texture2D = preload("res://art/menu_screen/menu_bg_day_ex.png")
const MenuBgScoresTexture: Texture2D = preload("res://art/menu_screen/menu_bg_scores.png")
const MenuBgSettingsTexture: Texture2D = preload("res://art/menu_screen/menu_bg_settings.png")
const MenuBgExitTexture: Texture2D = preload("res://art/menu_screen/menu_bg_exit.png")

const BG_COLOR_DAY_1_LIKE_GAME := Color("7CE194")
const BG_COLOR_DAY_2_LIKE_GAME := Color("E76F6F")
const BG_COLOR_DAY_3_LIKE_GAME := Color("E98BEA")
const BG_COLOR_DAY_EX_LIKE_GAME := Color("A7BD3A")
const BG_COLOR_DANGER := Color("b40404")
const BG_COLOR_SCORES := Color("83857a")
const BG_COLOR_SETTINGS := Color("2ec939")
const BG_COLOR_EXIT := Color("355f9d")

const STORY_MODE_OPTIONS := [
	{
		"label": "1",
		"value": Game.Minigame.STORY_DAY_01,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 0,
	},
	{
		"label": "2",
		"value": Game.Minigame.STORY_DAY_02,
		"texture": MenuBgDay02Texture,
		"color":BG_COLOR_DAY_2_LIKE_GAME,
		"min_story_mode_progress": 1,
	},
	{
		"label": "3",
		"value": Game.Minigame.STORY_DAY_03,
		"texture": MenuBgDay03Texture,
		"color": BG_COLOR_DAY_3_LIKE_GAME,
		"min_story_mode_progress": 2,
	},
	{
		"label": "EX",
		"value": Game.Minigame.STORY_DAY_EX,
		"texture": MenuBgDayExTexture,
		"color": BG_COLOR_DAY_EX_LIKE_GAME,
		"min_story_mode_progress": 3,
	}
]

const SCORE_ATTACK_MODE_OPTIONS := [
	{
		"label": "Día 1A",
		"value": Game.Minigame.SCORE_ATTACK_1A,
		"texture": MenuBgDay01Texture,
		"color":BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 0,
	},
	{
		"label": "Día 1B",
		"value": Game.Minigame.SCORE_ATTACK_1B,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 0,
	},
	{
		"label": "Día 1C",
		"value": Game.Minigame.SCORE_ATTACK_1C,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 1,
	},
	{
		"label": "Día 1D",
		"value": Game.Minigame.SCORE_ATTACK_1D,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 1,
	},
	{
		"label": "Día 2",
		"value": Game.Minigame.SCORE_ATTACK_2,
		"texture": MenuBgDay02Texture,
		"color": BG_COLOR_DAY_2_LIKE_GAME,
		"min_story_mode_progress": 2,
	},
	{
		"label": "Día 3A",
		"value": Game.Minigame.SCORE_ATTACK_3A,
		"texture": MenuBgDay03Texture,
		"color": BG_COLOR_DAY_3_LIKE_GAME,
		"min_story_mode_progress": 3,
	},
	{
		"label": "Día 3B",
		"value": Game.Minigame.SCORE_ATTACK_3B,
		"texture": MenuBgDay03Texture,
		"color": BG_COLOR_DAY_3_LIKE_GAME,
		"min_story_mode_progress": 3,
	},
]

@export_group("Debug", "_debug")
@export var _debug_is_cold_boot: bool:
	get:
		return _debug_is_cold_boot and OS.is_debug_build()
@export var _debug_skip_game_filter: bool:
	get:
		return _debug_skip_game_filter and OS.is_debug_build()

@onready var _is_ready := true
@onready var _title_screen := $TitleScreen
@onready var _logos_roll := $LogosRoll
@onready var _story_mode_game_selector := %StoryModeGameSelector as HSelector
@onready var _score_attack_game_selector := %ScoreAttackGameSelector as HSelector
@onready var _exit_game_btn := %ExitGameBtn
@onready var _confirm_exit_dialog := $ConfirmExitDialog
@onready var _unlocks_dialog := $UnlocksDialog
@onready var _progress_menu := %ProgressMenu
@onready var _settings_menu := %SettingsMenu
@onready var _main_menu := %MainMenu
@onready var _main_menu_box := %MainMenu/VBoxContainer
@onready var _game_title := %GameTitle
@onready var _show_scores_button := %ShowScoresBtn
@onready var _show_options_btn := %ShowOptionsBtn
@onready var _title_screen_bg := %TitleScreenBg
@onready var _version_label := $TitleScreen/VersionLabel as Label


func _ready() -> void:
	_version_label.text = Utils.get_game_version()
	_update_version_label_visibility()
	_remove_exit_btn_on_web()
	_start()


func _remove_exit_btn_on_web() -> void:
	if Utils.is_running_on_web():
		var main_menu_box_separation: float = \
				_main_menu_box.get_theme_constant("separation")
		_main_menu.offset_bottom -= \
				_exit_game_btn.size.y + main_menu_box_separation
		_exit_game_btn.visible = false


func _start() -> void:
	if Game.is_cold_boot or _debug_is_cold_boot:
		Game.is_cold_boot = false
		_enable_title_screen(false)
		_logos_roll.start()
	else:
		_enable_title_screen(true)


func _update_version_label_visibility() -> void:
	_version_label.visible = !_progress_menu.visible


func _get_enabled_story_mode_games() -> Array:
	if _debug_skip_game_filter:
		return STORY_MODE_OPTIONS
	
	var saved_data := SaveDataManager.save_data as SaveData
	return STORY_MODE_OPTIONS.filter(func(option):
		return option.min_story_mode_progress <= saved_data.latest_day_completed
	)


func _get_enabled_score_attack_games() -> Array:
	if _debug_skip_game_filter:
		return SCORE_ATTACK_MODE_OPTIONS
	
	var saved_data := SaveDataManager.save_data as SaveData
	return SCORE_ATTACK_MODE_OPTIONS.filter(func(option):
		return option.min_story_mode_progress <= saved_data.latest_day_completed
	)


func _set_day_options() -> void:
	var enabled_options: Array = _get_enabled_story_mode_games()
	_story_mode_game_selector.set_options(enabled_options)


func _set_score_attack_options() -> void:
	var enabled_options: Array = _get_enabled_score_attack_games()
	_score_attack_game_selector.set_options(enabled_options)


func _set_stars_count() -> void:
	_game_title.stars_count = SaveDataManager.save_data.stars.average()


func _set_title_type() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	_game_title.set_story_mode_progress(save_data.latest_day_completed)


func _enable_title_screen(show_screen: bool) -> void:
	_title_screen.visible = show_screen
	_title_screen_bg.visible = show_screen
	if not show_screen:
		_title_screen.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		_set_day_options()
		_set_score_attack_options()
		_set_stars_count()
		_set_title_type()
		_title_screen.process_mode = Node.PROCESS_MODE_ALWAYS
		_story_mode_game_selector.call_deferred("grab_focus")
		_notify_unlocks()


func _on_minigame_selection_changed(value) -> void:
	if _is_ready:
		_title_screen_bg.game_texture = value.texture
		_title_screen_bg.game_color = value.color


func _notify_unlocks() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	if save_data.latest_unlocked_day_notified >= save_data.latest_day_completed:
		return
	
	save_data.latest_unlocked_day_notified = save_data.latest_day_completed
	SaveDataManager.save()
	
	var story_progress: int = save_data.latest_day_completed
	var body: String
	if save_data.latest_day_completed >= 3:
		body = "Ya puedes comer:\n\nBuffets del día %s\n " % story_progress
	else:
		body = "Ya puedes comer:\n\nMenú del día %s\nBuffets del día %s\n " % \
				[story_progress + 1, story_progress]
	_unlocks_dialog.body_text = body
	_unlocks_dialog.visible = true


func _on_logos_roll_rolled() -> void:
	_logos_roll.visible = false
	_enable_title_screen(true)


func _on_show_scores_btn_focus_entered() -> void:
	_title_screen_bg.game_texture = MenuBgScoresTexture
	_title_screen_bg.game_color = BG_COLOR_SCORES


func _on_show_options_btn_focus_entered() -> void:
	_title_screen_bg.game_texture = MenuBgSettingsTexture
	_title_screen_bg.game_color = BG_COLOR_SETTINGS


func _on_exit_game_btn_focus_entered() -> void:
	_title_screen_bg.game_texture = MenuBgExitTexture
	_title_screen_bg.game_color = BG_COLOR_EXIT


func _on_settings_menu_dangerous_option_focused() -> void:
	_title_screen_bg.game_color = BG_COLOR_DANGER


func _on_settings_menu_dangerous_option_unfocused() -> void:
	_title_screen_bg.game_color = BG_COLOR_SETTINGS


func _on_minigame_selected(value) -> void:
	if value == Game.Minigame.STORY_DAY_EX:
		_unlocks_dialog.body_text = " \n¡Próximamente!\n¡No comas ansias!\n "
		_unlocks_dialog.visible = true
	else:
		Game.start(value)


func _on_story_mode_option_index_changed(index: int) -> void:
	if index != HSelector.SELECTED_NONE:
		_on_minigame_selection_changed(STORY_MODE_OPTIONS[index])


func _on_story_mode_game_selector_focus_entered() -> void:
	var index: int = _story_mode_game_selector.current_option_idx
	if index != HSelector.SELECTED_NONE:
		_on_minigame_selection_changed(STORY_MODE_OPTIONS[index])


func _on_score_attack_option_index_changed(index: int) -> void:
	if index != HSelector.SELECTED_NONE:
		_on_minigame_selection_changed(SCORE_ATTACK_MODE_OPTIONS[index])


func _on_score_attack_game_selector_focus_entered() -> void:
	var index: int = _score_attack_game_selector.current_option_idx
	if index != HSelector.SELECTED_NONE:
		_on_minigame_selection_changed(SCORE_ATTACK_MODE_OPTIONS[index])


func _on_show_scores_btn_pressed() -> void:
	_main_menu.visible = false
	_game_title.visible = false
	_progress_menu.visible = true


func _on_show_options_btn_pressed() -> void:
	_main_menu.visible = false
	_settings_menu.visible = true


func _on_exit_game_btn_pressed() -> void:
	_confirm_exit_dialog.visible = true


func _on_confirm_exit_dialog_negative_btn_pressed() -> void:
	_exit_game_btn.call_deferred("grab_focus")


func _on_confirm_exit_dialog_positive_btn_pressed() -> void:
	get_tree().quit()


func _on_unlocks_dialog_positive_btn_pressed() -> void:
	_story_mode_game_selector.call_deferred("grab_focus")


func _on_progress_menu_closed() -> void:
	_main_menu.visible = true
	_game_title.visible = true
	_show_scores_button.call_deferred("grab_focus")


func _on_settings_menu_closed() -> void:
	_main_menu.visible = true
	_show_options_btn.call_deferred("grab_focus")


func _on_progress_menu_visibility_changed() -> void:
	_update_version_label_visibility()
