extends Control


signal start_level_finished
signal dialogue_started
signal dialogue_event_requested(event: String)
signal dialogue_finished

const TwoLineTimedLabel = preload("res://scenes/_shared/ui/two_line_timed_label.gd")
const RpgDialogueBox = preload("res://scenes/day_ex/ui/rpg_dialogue_box.gd")

@onready var _rpg_dialogue_box: RpgDialogueBox = $RpgDialogueBox
@onready var _start_labels: TwoLineTimedLabel = $StartLabels
@onready var _black_screen: ColorRect = $BlackScreen
@onready var _pause_menu := $PauseMenu


func set_pause_menu_enabled(enabled: bool) -> void:
	_pause_menu.enabled = enabled


func show_level_start() -> void:
	_start_labels.start()


func show_black_screen(value: bool) -> void:
	_black_screen.visible = value


func play_dialogue(dialogue: Array[DialoguePage]) -> void:
	_rpg_dialogue_box.play(dialogue)
	await _rpg_dialogue_box.finished


func _on_start_labels_finished() -> void:
	start_level_finished.emit()


func _on_rpg_dialogue_box_finished() -> void:
	dialogue_finished.emit()


func _on_rpg_dialogue_box_started() -> void:
	dialogue_started.emit()


func _on_rpg_dialogue_box_event_requested(event: String) -> void:
	dialogue_event_requested.emit(event)
