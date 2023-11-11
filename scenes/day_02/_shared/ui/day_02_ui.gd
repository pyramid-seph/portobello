extends Control


signal start_level_finished
signal game_over_finished
signal level_beaten_finished

const LIVES_COUNTER_UPDATE_DELAY: float = 1.5

var _lives_counter_tween: Tween

@onready var _lives_counter := $LivesCounter/Label as Label
@onready var _score_label := $ScoreLabel as Label
@onready var _high_score_label := $HighScoreLabel as Label
@onready var _start_labels := $StartLabels
@onready var _game_over := $GameOver
@onready var _piece_of_cake := $PieceOfCake
@onready var _black_screen := $BlackScreen
@onready var _pause_menu := $PauseMenu


func show_level_start(mode: Game.Mode, index: int) -> void:
	var line_1: String
	if mode == Game.Mode.STORY:
		line_1 = "Plato %s" % (index + 1)
	else:
		line_1 = "Buffet %s" % (index + 1)
	_start_labels.text_1 = line_1
	_start_labels.start()


func show_game_over(new_high_score: bool) -> void:
	_game_over.text = "¡Qué indigestión!"
	if new_high_score:
		_game_over.text += "\n¡Nuevo récord!"
	_game_over.start()
	await _game_over.finished
	game_over_finished.emit()


func show_level_beaten() -> void:
	_piece_of_cake.start()
	await _piece_of_cake.finished
	level_beaten_finished.emit()


func show_black_screen(value: bool) -> void:
	_black_screen.visible = value


func update_lives_counter(value: int, immediate: bool = false) -> void:
	if _lives_counter_tween:
		_lives_counter_tween.kill()
		
	if immediate:
		_set_lives_counter(value)
	else:
		_lives_counter_tween = create_tween()
		_lives_counter_tween.tween_callback(func():
			_set_lives_counter(value)
		).set_delay(LIVES_COUNTER_UPDATE_DELAY)


func update_score(value: int) -> void:
	_score_label.text = str(value)


func update_high_score(value: int) -> void:
	if value < 0:
		_high_score_label.visible = false
	else:
		_high_score_label.visible = true
		_high_score_label.text = "Hi %s" % value


func set_pause_menu_enabled(enabled: bool) -> void:
	_pause_menu.enabled = enabled


func _set_lives_counter(value: int) -> void:
	_lives_counter.text = str(value)


func _on_start_label_timed_label_finished() -> void:
	start_level_finished.emit()

