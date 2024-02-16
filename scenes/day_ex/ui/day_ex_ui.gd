extends Control


signal start_level_finished

const TwoLineTimedLabel = preload("res://scenes/_shared/ui/two_line_timed_label.gd")

@onready var _start_labels: TwoLineTimedLabel = $StartLabels
@onready var _black_screen: ColorRect = $BlackScreen


func show_level_start() -> void:
	_start_labels.start()


func show_black_screen(value: bool) -> void:
	_black_screen.visible = value


func _on_start_labels_finished() -> void:
	start_level_finished.emit()
