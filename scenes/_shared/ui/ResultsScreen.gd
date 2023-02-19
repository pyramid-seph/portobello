extends Control


signal results_presented(total_score)

const BONUS_MULTIPLIER: int = 1000
const INITIAL_DELAY: float = 0.8
const LABELS_DELAY: float = 0.4
const LAST_INTERVAL: float = 4.0
const COMPLETED_DELAY: float = 4.0
const RESULTS_LABELS_COLOR: Color = Color.WHITE
const COMPLETE_LABELS_COLOR: Color = Color("F13030")

# TODO if this is the last level, print "reto completado"; otherwise print ¡Pan Comido!
@export var is_last_level: bool = false
@export var level_complete_text: String = "¡Pan comido!"
@export var last_level_complete_text: String = "¡Reto completado!"

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


func _ready() -> void:
	_ensure_reset_ui()


func start(lives: int, score: int, high_score: int) -> int:
	var bonus: int = BONUS_MULTIPLIER * lives
	var total_score: int = score + bonus
	var extra_lives: int = 0
	# TODO if is_last_level or not HISTORY_MODE
	if is_last_level:
		extra_lives = mini(
			floori(score / 1_000), 
			Day03PlayerData.MAX_LIVES - lives
		)
	_score_label.text = "Score = %s" % score
	_lives_bonus_label.text = "Bono = %s x 1000 = %s" % [lives, bonus]
	_total_score_label.text = "Total = %s" % total_score
	var lives_text = "vida"
	if extra_lives > 1:
		lives_text += "s"
	_extra_lives_label.text = "¡%s %s extra!" % [extra_lives, lives_text]
	_level_complete_label.text = _get_level_complete_text()
	_tween_results_screen(lives, score, total_score, high_score, extra_lives)
	return total_score


func _ensure_reset_ui() -> void:
	_background_color_rect.visible = false
	_results_container.visible = false
	_level_completed_container.visible = false
	_change_results_labels_color(Color.TRANSPARENT)
	Utils.change_label_color(_new_high_score_label, Color.TRANSPARENT)


func _tween_results_screen(lives: int, score: int, total_score: int, high_score: int, extra_lives: int) -> void:
	_results_container.visible = true
	_background_color_rect.visible = true
	_change_results_labels_color(Color.TRANSPARENT)
	Utils.change_label_color(_new_high_score_label, Color.TRANSPARENT)
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_callback(
		Utils.change_label_color.bind(_score_label, RESULTS_LABELS_COLOR)
	).set_delay(INITIAL_DELAY)
	_tween.tween_callback(
		Utils.change_label_color.bind(_lives_bonus_label, RESULTS_LABELS_COLOR)
	).set_delay(LABELS_DELAY)
	_tween.tween_callback(
		Utils.change_label_color.bind(_total_score_label, RESULTS_LABELS_COLOR)
	).set_delay(LABELS_DELAY)
	var extra_lives_delay: float = 0.0
	if extra_lives > 0:
		extra_lives_delay = LABELS_DELAY * 2
		_tween.tween_callback(
			Utils.change_label_color.bind(_extra_lives_label, RESULTS_LABELS_COLOR)
		).set_delay(extra_lives_delay)
	_tween.tween_callback(func():
		_results_container.visible = false
		_level_completed_container.visible = true
		if total_score > high_score:
			Utils.change_label_color(_new_high_score_label, COMPLETE_LABELS_COLOR)
	).set_delay(COMPLETED_DELAY - extra_lives_delay)
	_tween.tween_callback(func(): 
		results_presented.emit(total_score)
	).set_delay(LAST_INTERVAL)


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
