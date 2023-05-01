extends Node2D

@onready var _title_screen_bg := $TitleScreen/TitleScreenBg


func _ready() -> void:
	_test_title_screen_bg()


func _test_title_screen_bg() -> void:
	_title_screen_bg.game_color = Color.html("7CE194")
	_title_screen_bg.game_texture = preload("res://art/menu_screen/menu_bg_day_01.png")
	get_tree().create_timer(3.0, false).timeout.connect(func():
		_title_screen_bg.game_color = Color.html("E98BEA")
		_title_screen_bg.game_texture = preload("res://art/menu_screen/menu_bg_day_03.png")
	)
