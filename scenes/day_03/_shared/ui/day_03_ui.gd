extends Node

signal score_changed(new_val)
signal hi_score_changed(new_val)
signal lives_left_changed(new_val)
signal power_up_changed(new_val, max_val)
signal stamina_changed(new_val, max_val)
signal pause_state_changed(new_state)
signal level_state_changed(new_state)
signal boss_alert_finished

@export var player_data: Day03PlayerData

@onready var _boss_alert := $BossAlert
@onready var _start_labels := $StartLabels
@onready var _main_course_label := $MainCourseLabels


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


func _start_game_presentation() -> void:
	_start_labels.start()


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
	if new_state == Day03Level.LevelState.STARTING:
		_start_game_presentation()
	level_state_changed.emit(new_state)


func _on_day_03_level_waves_completed() -> void:
	_boss_alert.start()


func _on_boss_alert_finished():
	_main_course_label.visible = true
	_main_course_label.start()
	boss_alert_finished.emit()
	
