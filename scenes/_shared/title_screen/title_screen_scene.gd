extends Node

enum ScreenState {
	INTRO_LOGOS,
	ATTRACT_MODE,
	PRESS_TO_START,
	MENU
}

const MenuBgDay01Texture: Texture2D = preload("res://art/menu_screen/menu_bg_day_01.png")
const MenuBgDay02Texture: Texture2D = preload("res://art/menu_screen/menu_bg_day_02.png")
const MenuBgDay03Texture: Texture2D = preload("res://art/menu_screen/menu_bg_day_03.png")
const MenuBgDayExTexture: Texture2D = preload("res://art/menu_screen/menu_bg_day_ex.png")
const MenuBgScoresTexture: Texture2D = preload("res://art/menu_screen/menu_bg_scores.png")
const MenuBgSettingsTexture: Texture2D = preload("res://art/menu_screen/menu_bg_settings.png")
const MenuBgExitTexture: Texture2D = preload("res://art/menu_screen/menu_bg_exit.png")
const SfxCheated: AudioStream = preload("res://audio/sfx/sfx_title_screen_cheated.wav")
const SfxPressedStart: AudioStream = preload("res://audio/ui/ui_next.wav")

const CheatCode = preload("res://scenes/_shared/cheat_code.gd")
const Cutscene = preload("res://scenes/_shared/cutscenes/attract_mode_cutscene.gd")

const BG_COLOR_DAY_1_LIKE_GAME := Color("7CE194")
const BG_COLOR_DAY_2_LIKE_GAME := Color("E76F6F")
const BG_COLOR_DAY_3_LIKE_GAME := Color("E98BEA")
const BG_COLOR_DAY_EX_LIKE_GAME := Color("A7BD3A")
const BG_COLOR_DANGER := Color("b40404")
const BG_COLOR_SCORES := Color("83857a")
const BG_COLOR_SETTINGS := Color("2ec939")
const BG_COLOR_EXIT := Color("355f9d")

const STORY_MODE_OPTIONS: Array[Dictionary] = [
	{
		"label": "MINIGAME_NAME_STORY_MODE_0",
		"value": Game.Minigame.STORY_DAY_01,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 0,
	},
	{
		"label": "MINIGAME_NAME_STORY_MODE_1",
		"value": Game.Minigame.STORY_DAY_02,
		"texture": MenuBgDay02Texture,
		"color":BG_COLOR_DAY_2_LIKE_GAME,
		"min_story_mode_progress": 1,
	},
	{
		"label": "MINIGAME_NAME_STORY_MODE_2",
		"value": Game.Minigame.STORY_DAY_03,
		"texture": MenuBgDay03Texture,
		"color": BG_COLOR_DAY_3_LIKE_GAME,
		"min_story_mode_progress": 2,
	},
	{
		"label": "MINIGAME_NAME_STORY_MODE_3",
		"value": Game.Minigame.STORY_DAY_EX,
		"texture": MenuBgDayExTexture,
		"color": BG_COLOR_DAY_EX_LIKE_GAME,
		"min_story_mode_progress": 3,
	}
]

const SCORE_ATTACK_MODE_OPTIONS: Array[Dictionary] = [
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_0",
		"value": Game.Minigame.SCORE_ATTACK_1A,
		"texture": MenuBgDay01Texture,
		"color":BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 0,
	},
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_1",
		"value": Game.Minigame.SCORE_ATTACK_1B,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 0,
	},
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_2",
		"value": Game.Minigame.SCORE_ATTACK_1C,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 1,
	},
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_3",
		"value": Game.Minigame.SCORE_ATTACK_1D,
		"texture": MenuBgDay01Texture,
		"color": BG_COLOR_DAY_1_LIKE_GAME,
		"min_story_mode_progress": 1,
	},
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_4",
		"value": Game.Minigame.SCORE_ATTACK_2,
		"texture": MenuBgDay02Texture,
		"color": BG_COLOR_DAY_2_LIKE_GAME,
		"min_story_mode_progress": 2,
	},
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_5",
		"value": Game.Minigame.SCORE_ATTACK_3A,
		"texture": MenuBgDay03Texture,
		"color": BG_COLOR_DAY_3_LIKE_GAME,
		"min_story_mode_progress": 3,
	},
	{
		"label": "MINIGAME_NAME_SCORE_ATTACK_6",
		"value": Game.Minigame.SCORE_ATTACK_3B,
		"texture": MenuBgDay03Texture,
		"color": BG_COLOR_DAY_3_LIKE_GAME,
		"min_story_mode_progress": 3,
	},
]

@export_group("Debug", "_debug")
@export var _debug_ignore_game_progress: bool:
	get:
		return _debug_ignore_game_progress and OS.is_debug_build()
@export var _debug_skip_logos_roll: bool:
	get:
		return _debug_skip_logos_roll and OS.is_debug_build()

var _screen_state: ScreenState = ScreenState.INTRO_LOGOS
var _cheat_code_tween: Tween
var _press_to_start_tween: Tween

@onready var _title_screen := $TitleScreen
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
@onready var _ui_sounds: UiSounds = $TitleScreen/MainMenu/UiSounds
@onready var _bgm_player: SimpleBgmPlayer = $SimpleBgmPlayer
@onready var _k_cheat_code: CheatCode = $KCheatCode
@onready var _cheater_texture_rect: TextureRect = %CheaterTextureRect
@onready var _intro_logos_mngr: IntroLogosManager = $IntroLogosManager
@onready var _press_to_start_label: RichTextLabel = %PressToStartLabel
@onready var _press_to_start_container: PanelContainer = $TitleScreen/PressToStartContainer
@onready var _attract_mode_cutscene: Cutscene = $AttractModeCutscene
@onready var _attract_mode_delay_timer: Timer = $AttractModeDelayTimer


func _ready() -> void:
	_press_to_start_container.hide()
	_main_menu.hide()
	set_process_unhandled_input(false)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_version_label.text = Utils.get_game_version()
	_update_version_label_visibility()
	_remove_exit_btn_on_web()
	_set_day_options()
	_set_score_attack_options()
	_set_stars_count()
	_set_title_type()
	_start()


func _unhandled_input(event: InputEvent) -> void:
	if _screen_state == ScreenState.PRESS_TO_START and \
			event.is_action_pressed(&"start_game") and \
			not event.is_echo() and \
			not _attract_mode_delay_timer.is_stopped():
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		_on_start_pressed()


func _remove_exit_btn_on_web() -> void:
	if Utils.is_running_on_web():
		var main_menu_box_separation: float = \
				_main_menu_box.get_theme_constant("separation")
		_main_menu.offset_bottom -= \
				_exit_game_btn.size.y + main_menu_box_separation
		_exit_game_btn.visible = false


func _start() -> void:
	if Game.is_cold_boot:
		Game.is_cold_boot = false
		if _debug_skip_logos_roll:
			_change_screen_state.call_deferred(ScreenState.PRESS_TO_START)
		else:
			_change_screen_state(ScreenState.INTRO_LOGOS)
	else:
		_change_screen_state(ScreenState.MENU)


func _update_version_label_visibility() -> void:
	_version_label.visible = !_progress_menu.visible


func _get_enabled_story_mode_games() -> Array:
	if _debug_ignore_game_progress:
		return STORY_MODE_OPTIONS
	
	var saved_data := SaveDataManager.save_data as SaveData
	return STORY_MODE_OPTIONS.filter(func(option):
		return option.min_story_mode_progress <= saved_data.latest_day_completed
	)


func _get_enabled_score_attack_games() -> Array:
	if _debug_ignore_game_progress:
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


func _on_minigame_selection_changed(value) -> void:
	if is_node_ready():
		_title_screen_bg.game_texture = value.texture
		_title_screen_bg.game_color = value.color


func _notify_unlocks() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	if save_data.latest_unlocked_day_notified >= save_data.latest_day_completed:
		return
	
	save_data.latest_unlocked_day_notified = save_data.latest_day_completed
	SaveDataManager.save()
	
	var body: String
	var story_progress: int = save_data.latest_day_completed
	if story_progress >= 4:
		body = "INFO_DAY_EX_AVAILABLE"
	elif save_data.latest_day_completed == 3:
		body = tr("INFO_MINIGAME_UNLOCK_EX").format({
				unlocked_story_mode_minigame = story_progress
			})
	else:
		body = tr("INFO_MINIGAME_UNLOCK").format({
				unlocked_story_mode_minigame = (story_progress + 1), 
				unlocked_score_attack_mode_minigame = story_progress
			})
	_unlocks_dialog.body_text = body
	_unlocks_dialog.show()


func _start_listening_for_cheat_codes() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	_k_cheat_code.disabled = save_data.latest_day_completed >= 3
	Utils.safe_connect(_k_cheat_code.completed, _on_k_cheat_code_completed)


func _stop_listening_for_cheat_codes() -> void:
	_k_cheat_code.disabled = true


func _show_press_start_label() -> void:
	_press_to_start_container.show()
	if _press_to_start_tween:
		_press_to_start_tween.kill()
		_press_to_start_tween = null
	_press_to_start_tween = create_tween()
	_press_to_start_tween.set_loops()
	_press_to_start_tween.tween_property(_press_to_start_label, "self_modulate:a",
			1.0, 0.0).from(1.0)
	_press_to_start_tween.tween_interval(1.0)
	_press_to_start_tween.tween_property(_press_to_start_label, "self_modulate:a",
			0.0, 0.0)
	_press_to_start_tween.tween_interval(1.0)


func _on_start_pressed() -> void:
	SoundManager.play_sound(SfxPressedStart)
	_press_to_start_container.show()
	if _press_to_start_tween:
		_press_to_start_tween.kill()
		_press_to_start_tween = null
	_press_to_start_tween = create_tween()
	_press_to_start_tween.set_loops(4)
	_press_to_start_tween.tween_property(_press_to_start_label, "self_modulate:a",
			1.0, 0.0).from(1.0)
	_press_to_start_tween.tween_interval(0.1)
	_press_to_start_tween.tween_property(_press_to_start_label, "self_modulate:a",
			0.0, 0.0)
	_press_to_start_tween.tween_interval(0.1)
	_press_to_start_tween.finished.connect(func():
			_press_to_start_container.hide()
			_change_screen_state(ScreenState.MENU))


func _hide_press_start_label() -> void:
	_press_to_start_container.hide()
	if _press_to_start_tween:
		_press_to_start_tween.kill()
		_press_to_start_tween = null


func _update_press_to_start_label_text() -> void:
	var press_to_start_text: String =  "TITLE_SCREEN_PRESS_TO_START_"
	match InputUtils.get_main_input_device():
		InputUtils.InputDevice.GAMEPAD:
			press_to_start_text += "GAMEPAD"
		InputUtils.InputDevice.TOUCHSCREEN:
			press_to_start_text += "TOUCHSCREEN"
		_:
			press_to_start_text += "KEYBOARD"
	_press_to_start_label.text = press_to_start_text
	await get_tree().process_frame
	_press_to_start_container.reset_size()
	_press_to_start_container.position.y = 120.0


func _change_screen_state(new_state: ScreenState) -> void:
	_exit_current_screen_state()
	_enter_new_screen_state(new_state)


func _exit_current_screen_state() -> void:
	match _screen_state:
		ScreenState.INTRO_LOGOS:
			_exit_intro_logo_screen_state()
		ScreenState.ATTRACT_MODE:
			_exit_attract_mode_screen_state()
		ScreenState.PRESS_TO_START:
			_exit_press_start_screen_state()
		_: # Menu or unknown value.
			_exit_menu_screen_state()


func _enter_new_screen_state(new_state: ScreenState) -> void:
	_screen_state = new_state
	
	match _screen_state:
		ScreenState.INTRO_LOGOS:
			_enter_intro_logo_screen_state()
		ScreenState.ATTRACT_MODE:
			_enter_attract_mode_screen_state()
		ScreenState.PRESS_TO_START:
			_enter_press_start_screen_state()
		_: # Menu or unknown value.
			_enter_menu_screen_state()


func _enter_intro_logo_screen_state() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.INTRO_LOGOS
	_bgm_player.stop()
	_start_listening_for_cheat_codes()
	_intro_logos_mngr.play()


func _exit_intro_logo_screen_state() -> void:
	_intro_logos_mngr.stop()
	_stop_listening_for_cheat_codes()


func _enter_attract_mode_screen_state() -> void:
	_attract_mode_cutscene.play()


func _exit_attract_mode_screen_state() -> void:
	pass


func _enter_press_start_screen_state() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.START_GAME
	set_process_unhandled_input(true)
	_update_press_to_start_label_text()
	_show_press_start_label()
	_title_screen.show()
	_attract_mode_delay_timer.start()
	if not _bgm_player.is_playing():
		_bgm_player.play()


func _exit_press_start_screen_state() -> void:
	set_process_unhandled_input(false)
	_hide_press_start_label()
	_title_screen.hide()
	_attract_mode_delay_timer.stop()


func _enter_menu_screen_state() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.UI_MENU
	_title_screen.show()
	_main_menu.call_deferred("show")
	_ui_sounds.focus_node_no_sound.call_deferred(_story_mode_game_selector)
	_notify_unlocks()
	if not _bgm_player.is_playing():
		_bgm_player.play()


func _exit_menu_screen_state() -> void:
	_title_screen.hide()
	_main_menu.hide()


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_press_to_start_label_text()


func _on_intro_logos_manager_finished() -> void:
	_change_screen_state(ScreenState.ATTRACT_MODE)


func _on_attract_mode_cutscene_finished() -> void:
	_change_screen_state(ScreenState.PRESS_TO_START)


func _on_attract_mode_delay_timer_timeout() -> void:
	_change_screen_state(ScreenState.ATTRACT_MODE)


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
	_ui_sounds.focus_node_no_sound.call_deferred(_exit_game_btn)
	_exit_game_btn.grab_focus.call_deferred()


func _on_confirm_exit_dialog_positive_btn_pressed() -> void:
	get_tree().quit()


func _on_unlocks_dialog_positive_btn_pressed() -> void:
	_ui_sounds.focus_node_no_sound.call_deferred(_story_mode_game_selector)
	_story_mode_game_selector.grab_focus.call_deferred()


func _on_progress_menu_closed() -> void:
	_main_menu.visible = true
	_game_title.visible = true
	_ui_sounds.focus_node_no_sound.call_deferred(_show_scores_button)
	_show_scores_button.grab_focus.call_deferred()


func _on_settings_menu_closed() -> void:
	_main_menu.visible = true
	_ui_sounds.focus_node_no_sound.call_deferred(_show_options_btn)
	_show_options_btn.grab_focus.call_deferred()


func _on_progress_menu_visibility_changed() -> void:
	_update_version_label_visibility()


func _on_k_cheat_code_completed() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	save_data.latest_day_completed = 100
	save_data.latest_unlocked_day_notified = 100
	SaveDataManager.save()
	
	if _cheat_code_tween:
		_cheat_code_tween.kill()
	_cheat_code_tween = create_tween()
	_cheat_code_tween.set_loops(3)
	_cheat_code_tween.tween_callback(SoundManager.play_sound.bind(SfxCheated))
	_cheat_code_tween.tween_property(_cheater_texture_rect, "self_modulate:a",
			1.0, 0.1).from(0)
	_cheat_code_tween.tween_property(_cheater_texture_rect, "self_modulate:a",
			0.0, 0.1)
