extends Control


signal start_level_finished
signal game_over_finished
signal level_beaten_finished
signal time_out_finished

const LIVES_COUNTER_UPDATE_DELAY: float = 1.5

var _lives_counter_tween: Tween
var _inverted_controls_sign_tween: Tween

@onready var _lives_counter: Label = $LivesCounter/Label
@onready var _treats_counter: Label = $TreatsCounter/Label
@onready var _high_score_label: Label = $HighScoreLabel
@onready var _stamina_bar: TextureProgressBar = %ProgressBar
@onready var _stamina_bar_container = $StaminaBar
@onready var _start_labels := $StartLabels
@onready var _game_over := $GameOver
@onready var _piece_of_cake := $PieceOfCake
@onready var _time_out := $TimeOut
@onready var _dialogue_box := $DialogueBox as DialogueBox
@onready var _black_screen := $BlackScreen
@onready var _pause_menu := $PauseMenu
@onready var _inverted_controls_sign := $InvertedControlsSign
@onready var _level_name: Label = $LevelName


func show_level_start(mode: Game.Mode, index: int) -> void:
	var line_1: String
	if mode == Game.Mode.STORY:
		line_1 = tr("LEVEL_START_LINE_0_STORY_MODE").format(
				{ level_pos = (index + 1) }
		)
	else:
		line_1 = "LEVEL_START_LINE_0_SCORE_ATTACK"
	_start_labels.text_1 = line_1
	_start_labels.start()


func show_game_over(new_high_score: bool) -> void:
	_game_over.text = tr("LEVEL_GAME_OVER")
	if new_high_score:
		_game_over.text += "\n\n"
		_game_over.text += tr("LEVEL_NEW_HIGH_SCORE")
	_game_over.start()
	await _game_over.finished
	game_over_finished.emit()


func show_level_beaten() -> void:
	_piece_of_cake.start()
	await _piece_of_cake.finished
	level_beaten_finished.emit()


func show_time_up() -> void:
	_time_out.start()
	await _time_out.finished
	time_out_finished.emit()


func show_inverted_controls_alert(are_inverted_controls: bool) -> void:
	if _inverted_controls_sign_tween:
		_inverted_controls_sign_tween.kill()
	
	_inverted_controls_sign.visible = false
	if are_inverted_controls:
		_inverted_controls_sign_tween = create_tween()
		_inverted_controls_sign_tween.set_loops(5)
		_inverted_controls_sign_tween.tween_interval(0.25)
		_inverted_controls_sign_tween.tween_callback(func():
			_inverted_controls_sign.visible = !_inverted_controls_sign.visible
		)
	else:
		_inverted_controls_sign_tween = null


func show_black_screen(value: bool) -> void:
	_black_screen.visible = value


func update_treats_counter(value: int) -> void:
	_treats_counter.text = str(value)


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


func update_stamina_bar(value: float, max_value: float) -> void:
	_stamina_bar.value = Utils.round_up(value, _stamina_bar.step)
	_stamina_bar.max_value = max_value


func update_high_score(value: int) -> void:
	if value < 0:
		_high_score_label.visible = false
	else:
		_high_score_label.visible = true
		_high_score_label.text = "Hi %s" % value


func set_is_stamina_bar_visible(value: bool) -> void:
	_stamina_bar_container.visible = value


func play_dialogue(dialogue: Array[DialogueLine]) -> void:
	_dialogue_box.dialogue = dialogue
	_dialogue_box.start()


func stop_dilogue() -> void:
	_dialogue_box.stop()


func set_pause_menu_enabled(enabled: bool) -> void:
	_pause_menu.enabled = enabled


func show_level_name(mode: Game.Mode, level_index: int,
		total_levels: int) -> void:
	if mode == Game.Mode.STORY:
		_level_name.visible = true
		_level_name.text = tr("LEVEL_DAY_01_LEVEL_NAME_STORY_MODE").format(
				{
					level_pos = (level_index + 1),
					total_levels = total_levels,
				}
		)
	else:
		_level_name.visible = false


func hide_level_name() -> void:
	_level_name.visible = false


func _set_lives_counter(value: int) -> void:
	_lives_counter.text = str(value)


func _on_start_label_timed_label_finished() -> void:
	start_level_finished.emit()
