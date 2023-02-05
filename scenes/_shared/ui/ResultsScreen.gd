@tool
extends Control


signal results_presented

const BONUS_MULTIPLIER: int = 1000
const INITIAL_DELAY: float = 0.8
const LABELS_INTERVAL: float = 0.4
const LAST_INTERVAL: float = 4.0

@export var preview: bool = false:
	set(value):
		preview = value
		if Engine.is_editor_hint():
			if _container: _container.visible = preview
	get:
		return preview

var _tween: Tween

@onready var _container := $ColorRect
@onready var _score_label := %ScoreLabel as Label
@onready var _lives_bonus_label := %LivesBonusLabel as Label
@onready var _total_score_label := %TotalScoreLabel as Label


func _ready() -> void:
	if Engine.is_editor_hint():
		_container.visible = preview
	else:
		_container.visible = false
		_change_all_labels_color(Color.TRANSPARENT)


func start(lives: int, score: int) -> int:
	var bonus: int = BONUS_MULTIPLIER * lives
	var total_score: int = score + bonus
	_score_label.text = "Score = %s" % score
	_lives_bonus_label.text = "Bono = %s x 1000 = %s" % [lives, bonus]
	_total_score_label.text = "Total = %s" % total_score
	_tween_results_screen()
	return total_score


func _tween_results_screen() -> void:
	_container.visible = true
	_change_all_labels_color(Color.TRANSPARENT)
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_interval(INITIAL_DELAY)
	_tween.tween_callback(Utils.change_label_color.bind(_score_label, Color.WHITE))
	_tween.tween_interval(LABELS_INTERVAL)
	_tween.tween_callback(Utils.change_label_color.bind(_lives_bonus_label, Color.WHITE))
	_tween.tween_interval(LABELS_INTERVAL)
	_tween.tween_callback(Utils.change_label_color.bind(_total_score_label, Color.WHITE))
	_tween.tween_interval(LAST_INTERVAL)
	_tween.tween_callback(func(): 
		results_presented.emit()
		_container.visible = false
	)


func _change_all_labels_color(color: Color) -> void:
	Utils.change_label_color(_score_label, color)
	Utils.change_label_color(_lives_bonus_label, color)
	Utils.change_label_color(_total_score_label, color)
