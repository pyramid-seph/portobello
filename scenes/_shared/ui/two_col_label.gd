@tool
extends PanelContainer


@export var text_1: String:
	set(value):
		text_1 = value
		_on_text_1_set()
@export var text_2: String:
	set(value):
		text_2 = value
		_on_text_2_set()

@onready var _is_ready := true
@onready var _text_1_label := %Text1Label as Label
@onready var _text_2_label := %Text2Label as Label


func _ready() -> void:
	_on_text_1_set()
	_on_text_2_set()


func _on_text_1_set() -> void:
	if _is_ready:
		_text_1_label.text = tr(text_1)


func _on_text_2_set() -> void:
	if _is_ready:
		_text_2_label.text = tr(text_2)
