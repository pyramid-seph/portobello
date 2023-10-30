extends Control


signal calculated(new_high_score: int, stars: int)
signal finished(total_score: int, extra_lives: int, stars: int)

enum StarsEvaluationMode {
	LIVES,
	SCORE,
}

const BONUS_MULTIPLIER: int = 1000
const MAX_LIVES: int = 9
const LEVEL_RESULTS_INITIAL_INTERVAL_SEC: float = 0.8
const LEVEL_RESULTS_LABELS_DELAY_SEC: float = 0.4
const LEVEL_RESULTS_LAST_INTERVAL_SEC: float = 3.2
const LEVEL_COMPLETED_DURATION_SEC: float = 3.2
const STARS_DELAY_SEC: float = 0.6
const STARS_DURATION_SEC: float = 0.4
const STARS_LAST_INTERVAL_SEC: float = 1.4
const RESULTS_LABELS_COLOR: Color = Color.WHITE
const COMPLETE_LABELS_COLOR: Color = Color("F13030")
const MINIGAME_COMPLETE_TEXT: String = "¡Reto completado!"
const STARS_RESULT_NONE_TEXT = "¡Qué mal!"
const STARS_RESULT_ONE_TEXT: String = "¡Yawn!"
const STARS_RESULT_TWO_TEXT: String = "¡No está mal!"
const STARS_RESULT_THREE_TEXT: String = "¡Bien!"
const STARS_RESULT_FOUR_TEXT: String = "¡Muy bien!"
const STARS_RESULT_FIVE_TEXT: String = "¡Prrrrrrfecto!"

@export var _skip_level_results_screen: bool
@export var _skip_minigame_results_screen: bool

@export_group("Stars", "_stars")
@export var _stars_evaluation_mode: StarsEvaluationMode
@export var _stars_threshold_one: int
@export var _stars_threshold_two: int
@export var _stars_threshold_three: int
@export var _stars_threshold_four: int
@export var _stars_threshold_five: int

var _tween: Tween
var _is_last_level: bool
var _game_mode: Game.Mode
var _bonus: int
var _total_score: int
var _extra_lives: int
var _stars: int
var _lives: int
var _score: int
var _curr_high_score: int

@onready var _background_color_rect := $ColorRect
@onready var _results_container := $ColorRect/MarginContainer/ResultsContainer
@onready var _new_curr_high_score_label := %NewHighScoreLabel as Label
@onready var _level_completed_container := $ColorRect/LevelCompletedContainer
@onready var _score_label := %ScoreLabel as Label
@onready var _lives_bonus_label := %LivesBonusLabel as Label
@onready var _total_score_label := %TotalScoreLabel as Label
@onready var _extra_lives_label := %ExtraLivesLabel as Label
@onready var _stars_label := %StarsLabel as Label
@onready var _evaluation_label := %EvaluationLabel as Label
@onready var _stars_container := $ColorRect/StarsContainer


func _ready() -> void:
	_ensure_reset_ui()


func start(game_mode: Game.Mode, is_last_level: bool, lives: int, score: int, high_score: int) -> void:
	_lives = lives
	_score = score
	_curr_high_score = high_score
	_game_mode = game_mode
	_is_last_level = is_last_level
	
	_bonus = 0 if _skip_level_results_screen else BONUS_MULTIPLIER * lives
	_total_score = score + _bonus
	_extra_lives = 0 if _skip_level_results_screen else \
			_calculate_extra_lives(_lives, _total_score)
	_stars = _calculate_stars(_lives, _total_score)
	
	var new_high_score = maxi(_curr_high_score, _total_score)
	calculated.emit(new_high_score, _stars)
	
	await _show_results()
	finished.emit(_total_score, _extra_lives, _stars)


func _calculate_extra_lives(lives: int, score: int) -> int:
	var extra_lives: int = 0
	if _game_mode == Game.Mode.STORY and not _is_last_level:
		var candidate_lives: int = floori(score / 1_000.0)
		extra_lives = mini(candidate_lives, MAX_LIVES - lives)
	return extra_lives


func _calculate_stars(lives: int, score: int) -> int:
	if _game_mode != Game.Mode.STORY or not _is_last_level:
		return 0
	
	if _stars_evaluation_mode == StarsEvaluationMode.LIVES:
		return _calculate_stars_by(lives)
	return _calculate_stars_by(score)


func _calculate_stars_by(value: int) -> int:
	var stars: int = 0
	if value >= _stars_threshold_five:
		stars = 5
	elif value >= _stars_threshold_four:
		stars = 4
	elif value >= _stars_threshold_three:
		stars = 3
	elif value >= _stars_threshold_two:
		stars = 2
	elif value >= _stars_threshold_one:
		stars = 1
	return stars


func _get_stars_result_text(stars: int) -> String:
	match stars:
		1:
			return STARS_RESULT_ONE_TEXT
		2:
			return STARS_RESULT_TWO_TEXT
		3:
			return STARS_RESULT_THREE_TEXT
		4:
			return STARS_RESULT_FOUR_TEXT
		5:
			return STARS_RESULT_FIVE_TEXT
		_:
			return STARS_RESULT_NONE_TEXT


func _change_results_labels_color(color: Color) -> void:
	Utils.change_label_color(_score_label, color)
	Utils.change_label_color(_lives_bonus_label, color)
	Utils.change_label_color(_total_score_label, color)
	Utils.change_label_color(_extra_lives_label, color)


func _build_extra_lives_text(extra_lives: int) -> String:
	if extra_lives < 1:
		return ""
	
	var lives_text = "vida"
	if extra_lives > 1:
		lives_text += "s"
	return "¡%s %s extra!" % [extra_lives, lives_text]


func _setup_label_texts() -> void:
	_score_label.text = "Score = %s" % _score
	_lives_bonus_label.text = "Bono = %s x 1000 = %s" % [_lives, _bonus]
	_total_score_label.text = "Total = %s" % _total_score
	_extra_lives_label.text = _build_extra_lives_text(_extra_lives)
	_evaluation_label.text = _get_stars_result_text(_stars)


func _ensure_reset_ui() -> void:
	_background_color_rect.visible = false
	_results_container.visible = false
	_level_completed_container.visible = false
	_stars_container.visible = false
	_evaluation_label.visible = false
	_stars_label.text = ""
	_change_results_labels_color(Color.TRANSPARENT)
	Utils.change_label_color(_new_curr_high_score_label, Color.TRANSPARENT)


func _tween_level_results() -> void:
	_tween.tween_callback(func(): 
		_results_container.visible = true
		_change_results_labels_color(Color.TRANSPARENT)
	)
	_tween.tween_interval(LEVEL_RESULTS_INITIAL_INTERVAL_SEC)
	_tween.tween_callback(func(): Utils.change_label_color(_score_label, RESULTS_LABELS_COLOR))
	_tween.tween_interval(LEVEL_RESULTS_LABELS_DELAY_SEC)
	_tween.tween_callback(func(): Utils.change_label_color(_lives_bonus_label, RESULTS_LABELS_COLOR))
	_tween.tween_interval(LEVEL_RESULTS_LABELS_DELAY_SEC)
	_tween.tween_callback(func(): Utils.change_label_color(_total_score_label, RESULTS_LABELS_COLOR))
	_tween.tween_interval(LEVEL_RESULTS_LABELS_DELAY_SEC)
	if _extra_lives > 0:
		_tween.tween_interval(LEVEL_RESULTS_LABELS_DELAY_SEC)
		_tween.tween_callback(func(): Utils.change_label_color(_extra_lives_label, RESULTS_LABELS_COLOR))
	_tween.tween_interval(LEVEL_RESULTS_LAST_INTERVAL_SEC)
	_tween.tween_callback(func(): _results_container.visible = false)


func _tween_minigame_results() -> void:
	if not _is_last_level:
		return
	
	_tween.tween_callback(func():
		_level_completed_container.visible = true
		var high_score_label_color
		if _total_score > _curr_high_score:
			high_score_label_color = COMPLETE_LABELS_COLOR
		else:
			high_score_label_color = Color.TRANSPARENT
		Utils.change_label_color(_new_curr_high_score_label, high_score_label_color)
	)
	_tween.tween_interval(LEVEL_COMPLETED_DURATION_SEC)
	_tween.tween_callback(func():
		_level_completed_container.visible = false
	)


func _tween_stars_results() -> void:
	if _game_mode != Game.Mode.STORY or not _is_last_level:
		return
	
	_tween.tween_callback(func():
		_stars_container.visible = true
		_evaluation_label.visible = false
		_stars_label.text = ""
	)
	_tween.tween_interval(STARS_DELAY_SEC)
	if _stars < 1:
		_tween.tween_callback(func():
			_stars_label.text = "¡Cero!"
		)
		_tween.tween_interval(STARS_DURATION_SEC)
	else:
		for i in _stars:
			_tween.tween_callback(func():
				_stars_label.text += "*" if i == 0 else " *"
			)
			_tween.tween_interval(STARS_DURATION_SEC)
	_tween.tween_callback(func():
		_evaluation_label.visible = true
	)
	_tween.tween_interval(STARS_LAST_INTERVAL_SEC)
	_tween.tween_callback(func():
		_stars_container.visible = false
	)


func _show_results() -> Signal:
	visible = true
	_setup_label_texts()
	
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func(): _background_color_rect.visible = true)
	if not _skip_level_results_screen:
		_tween_level_results()
	if not _skip_minigame_results_screen:
		_tween_minigame_results()
	_tween_stars_results()
	_tween.tween_callback(func(): _background_color_rect.visible = false)
	return _tween.finished
