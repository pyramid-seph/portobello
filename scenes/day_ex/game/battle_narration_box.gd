extends PanelContainer


@onready var _narration_label: RichTextLabel = %NarrationLabel


func say(what: String, require_user_input: bool = false) -> void:
	_narration_label.text = what
	if require_user_input:
		await Input.is_action_just_pressed("fire")
		_narration_label.text = ""

func enable_input() -> void:
	pass
