extends Control


signal finished(total_score: int, extra_lives: int, stars: int)

enum StarsEvaluationMode {
	LIVES,
	SCORE,
}

const Utils = preload("res://scenes/_shared/utils.gd")
const BONUS_MULTIPLIER: int = 1000
const INITIAL_DELAY: float = 0.8
const LABELS_DELAY: float = 0.4
const LAST_INTERVAL: float = 4.0
const COMPLETED_DELAY: float = 4.0
const RESULTS_LABELS_COLOR: Color = Color.WHITE
const COMPLETE_LABELS_COLOR: Color = Color("F13030")
const MAX_LIVES = 9

# TODO if this is the last level, print "reto completado"; otherwise print ¡Pan Comido!
@export var is_last_level: bool = false
@export var level_complete_text: String = "¡Pan comido!"
@export var last_level_complete_text: String = "¡Reto completado!"

@export_group("Stars", "_stars")
@export var _stars_evaluation_mode: StarsEvaluationMode
@export var _stars_threshold_two: int
@export var _stars_threshold_three: int
@export var _stars_threshold_four: int
@export var _stars_threshold_five: int

var _tween: Tween

@onready var _background_color_rect := $ColorRect
@onready var _results_container := $ColorRect/MarginContainer/ResultsContainer
@onready var _new_high_score_label := %NewHighScoreLabel as Label
@onready var _level_completed_container := $ColorRect/LevelCompletedContainer
@onready var _score_label := %ScoreLabel as Label
@onready var _lives_bonus_label := %LivesBonusLabel as Label
@onready var _total_score_label := %TotalScoreLabel as Label
@onready var _level_complete_label := %LevelCompleteLabel as Label
@onready var _extra_lives_label := %ExtraLivesLabel as Label
@onready var _stars_label := %StarsLabel as Label
@onready var _evaluation_label := %EvaluationLabel as Label
@onready var _stars_container := $ColorRect/StarsContainer


func _ready() -> void:
	_ensure_reset_ui()


func start(lives: int, score: int, high_score: int) -> void:
	var bonus: int = BONUS_MULTIPLIER * lives
	var total_score: int = score + bonus
	var extra_lives: int = 0
	# TODO if is_last_level or not HISTORY_MODE
	if is_last_level:
		extra_lives = mini(score / 1_000, MAX_LIVES - lives)
	_score_label.text = "Score = %s" % score
	_lives_bonus_label.text = "Bono = %s x 1000 = %s" % [lives, bonus]
	_total_score_label.text = "Total = %s" % total_score
	var lives_text = "vida"
	if extra_lives > 1:
		lives_text += "s"
	_extra_lives_label.text = "¡%s %s extra!" % [extra_lives, lives_text]
	_level_complete_label.text = _get_level_complete_text()
	var stars = _calculate_stars(lives, total_score)
	_tween_results_screen(lives, score, total_score, high_score, extra_lives, stars)


func _calculate_stars(lives: int, score: int) -> int:
	if _stars_evaluation_mode == StarsEvaluationMode.LIVES:
		return _calculate_stars_by(lives)
	return _calculate_stars_by(score)


func _calculate_stars_by(value: int) -> int:
	var stars = 1
	if value >= _stars_threshold_five:
		stars = 5
	elif value >= _stars_threshold_four:
		stars = 4
	elif value >= _stars_threshold_three:
		stars = 3
	elif value >= _stars_threshold_two:
		stars = 2
	return stars


func _ensure_reset_ui() -> void:
	_background_color_rect.visible = false
	_results_container.visible = false
	_level_completed_container.visible = false
	_stars_container.visible = false
	_evaluation_label.visible = false
	_stars_label.text = ""
	_change_results_labels_color(Color.TRANSPARENT)
	Utils.change_label_color(_new_high_score_label, Color.TRANSPARENT)


func _tween_results_screen(lives: int, score: int, total_score: int, high_score: int, extra_lives: int, stars: int) -> void:
	_results_container.visible = true
	_background_color_rect.visible = true
	_change_results_labels_color(Color.TRANSPARENT)
	Utils.change_label_color(_new_high_score_label, Color.TRANSPARENT)
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func():
		Utils.change_label_color(_score_label, RESULTS_LABELS_COLOR)
	).set_delay(INITIAL_DELAY)
	_tween.tween_callback(func():
		Utils.change_label_color(_lives_bonus_label, RESULTS_LABELS_COLOR)
	).set_delay(LABELS_DELAY)
	_tween.tween_callback(func():
		Utils.change_label_color(_total_score_label, RESULTS_LABELS_COLOR)
	).set_delay(LABELS_DELAY)
	var extra_lives_delay: float = 0.0
	if extra_lives > 0:
		extra_lives_delay = LABELS_DELAY * 2
		_tween.tween_callback(func():
			Utils.change_label_color(_extra_lives_label, RESULTS_LABELS_COLOR)
		).set_delay(extra_lives_delay)
	_tween.tween_callback(func():
		_results_container.visible = false
		_level_completed_container.visible = true
		if total_score > high_score:
			Utils.change_label_color(_new_high_score_label, COMPLETE_LABELS_COLOR)
	).set_delay(COMPLETED_DELAY - extra_lives_delay)
	_tween.tween_interval(LAST_INTERVAL)
	
	if stars > 0:
		_tween.tween_callback(func():
			_level_completed_container.visible = false
			_stars_container.visible = true
			_evaluation_label.visible = false
			_stars_label.text = ""
		)
		for i in stars:
			_tween.tween_interval(0.4)
			_tween.tween_callback(func():
				_stars_label.text += "*" if i == 0 else " *"
			)
		_tween.tween_callback(func():
			_evaluation_label.text = _get_stars_evaluation_name(stars)
			_evaluation_label.visible = true
		)
		_tween.tween_interval(1.8)
	_tween.finished.connect(func(): 
		finished.emit(total_score, extra_lives, stars)
	)


func _get_stars_evaluation_name(stars: int) -> String:
	match stars:
		1:
			return "¡Yawn!"
		2:
			return "¡No está mal!"
		3:
			return "¡Bien!"
		4:
			return "¡Muy bien!"
		5:
			return "¡Prrrrrrfecto!"
		_:
			return ""


func _get_level_complete_text() -> String:
	if is_last_level:
		return "¡Pan comido!\n "
	else:
		return "¡Reto completado!\n "


func _change_results_labels_color(color: Color) -> void:
	Utils.change_label_color(_score_label, color)
	Utils.change_label_color(_lives_bonus_label, color)
	Utils.change_label_color(_total_score_label, color)
	Utils.change_label_color(_extra_lives_label, color)
