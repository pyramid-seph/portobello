class_name SkipIndicator
extends PanelContainer


@onready var _skip_progress_bar: TextureProgressBar = %SkipProgressBar


func set_progress(value: float) -> void:
	_skip_progress_bar.value = value
