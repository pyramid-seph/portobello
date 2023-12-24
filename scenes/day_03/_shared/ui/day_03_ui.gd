class_name  Day03Ui
extends Control

signal score_changed(new_val)
signal hi_score_changed(new_val)
signal lives_left_changed(new_val)
signal power_up_changed(new_val, max_val)
signal stamina_changed(new_val, max_val)
signal pause_state_changed(new_state)
signal level_state_changed(new_state)
signal boss_alert_finished
signal main_course_presented

@export var player_data: Day03PlayerData

@onready var _boss_alert := $BossAlert
@onready var _start_labels := $StartLabels
@onready var _main_course_label := $MainCourseLabels
@onready var _score_label := $Score
@onready var _hi_score_label := $HiScore
@onready var _bars := $BarsMargin/Bars
@onready var _black_screen := $BlackScreen
@onready var _pause_menu := $PauseMenu
@onready var _lives_counter := $LivesCounter


func _ready() -> void:
	player_data.score_updated.connect(_on_player_data_score_updated)
	player_data.hi_score_updated.connect(_on_player_data_hi_score_updated)
	player_data.power_up_count_updated.connect(_on_player_data_power_up_count_updated)
	player_data.remaining_lives_updated.connect(_on_player_data_remaining_lives_updated)
	player_data.stamina_updated.connect(_on_player_data_remaining_stamina_updated)

	_on_player_data_score_updated()
	_on_player_data_hi_score_updated()
	_on_player_data_remaining_lives_updated()
	_on_player_data_power_up_count_updated()


func start_main_course_presentation(_duration_sec: float = -1) -> void:
	_main_course_label.visible = true
	_main_course_label.start(_duration_sec)


func change_bars_visibility(value: bool) -> void:
	_bars.visible = value


func change_score_visibility(value: bool) -> void:
	_score_label.visible = value
	_hi_score_label.visible = value


func change_lives_visibility(value: bool) -> void:
	_lives_counter.visible = value


func change_black_screen_visibility(value: bool) -> void:
	_black_screen.visible = value


func start_game_presentation(mode: Game.Mode, index: int) -> void:
	var line_1: String
	if mode == Game.Mode.STORY:
		line_1 = tr("LEVEL_START_LINE_0_STORY_MODE").format(
				{ level_pos = (index + 1) }
		)
	else:
		line_1 = "LEVEL_START_LINE_0_SCORE_ATTACK"
	_start_labels.text_1 = line_1
	_start_labels.start()


func set_pause_menu_enabled(enabled: bool) -> void:
	_pause_menu.enabled = enabled


func _on_player_data_score_updated() -> void:
	score_changed.emit(player_data.score)


func _on_player_data_hi_score_updated() -> void:
	hi_score_changed.emit(player_data.hi_score)


func _on_player_data_power_up_count_updated() -> void:
	power_up_changed.emit(player_data.power_up_count, player_data.MAX_POWER_UP)


func _on_player_data_remaining_lives_updated() -> void:
	lives_left_changed.emit(player_data.lives)


func _on_player_data_remaining_stamina_updated() -> void:
	stamina_changed.emit(player_data.stamina, player_data.MAX_STAMINA)


func _on_day_03_level_pause_state_changed(new_state: bool) -> void:
	pause_state_changed.emit(new_state)


func _on_day_03_level_level_state_changed(new_state: int) -> void:
	match new_state:
		Day03Level.LevelState.STARTING:
			visible = true
		Day03Level.LevelState.SHOWING_RESULTS:
			visible = false
		_:
			visible = true
	level_state_changed.emit(new_state)


func _on_day_03_level_waves_completed() -> void:
	_boss_alert.start()


func _on_boss_alert_finished():
	boss_alert_finished.emit()


func _on_main_course_labels_finished() -> void:
	main_course_presented.emit()
