extends PanelContainer


@onready var _narration_label: RichTextLabel = %NarrationLabel


func say(what: String) -> void:
	_narration_label.text = what
