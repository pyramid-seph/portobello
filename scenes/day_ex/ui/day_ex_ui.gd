extends Control


signal start_level_finished

const QuestIndicator = preload("res://scenes/day_ex/ui/quest_indicator.gd")
const TwoLineTimedLabel = preload("res://scenes/_shared/ui/two_line_timed_label.gd")

@onready var _quest_indicator: QuestIndicator = $QuestIndicator
@onready var _start_labels: TwoLineTimedLabel = $StartLabels
@onready var _black_screen: ColorRect = $BlackScreen
@onready var _pause_menu := $PauseMenu


func set_step_text(text: String) -> void:
	_quest_indicator.set_step_text(text)


func set_pause_menu_enabled(enabled: bool) -> void:
	_pause_menu.enabled = enabled


func show_level_start() -> void:
	_start_labels.start()


func show_black_screen(value: bool) -> void:
	_black_screen.visible = value


func hide_quest_indicator() -> void:
	_quest_indicator.disappear(true)


func show_quest_indicator() -> void:
	_quest_indicator.appear()


func _on_start_labels_finished() -> void:
	start_level_finished.emit()
