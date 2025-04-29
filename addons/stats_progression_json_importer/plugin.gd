@tool
extends EditorPlugin

const DmgPreviewerScene = preload("res://addons/stats_progression_json_importer/damage_previewer.tscn")

const DMG_PREVIEWER_TOOL_NAME = "DMG Previewer"

var _dmg_previewer_window: Window
var _import_plugin: EditorImportPlugin

func _enter_tree() -> void:
	_import_plugin = preload("import_plugin.gd").new()
	add_import_plugin(_import_plugin)
	add_tool_menu_item(DMG_PREVIEWER_TOOL_NAME, _open_dmg_previewer_window)


func _exit_tree() -> void:
	remove_import_plugin(_import_plugin)
	_import_plugin = null
	
	remove_tool_menu_item(DMG_PREVIEWER_TOOL_NAME)
	_close_dmg_previewer_window()


func _open_dmg_previewer_window() -> void:
	if not _dmg_previewer_window:
		_dmg_previewer_window = Window.new()
		_dmg_previewer_window.title = "DMG Previewer"
		_dmg_previewer_window.min_size = Vector2(800.0, 640.0)
		_dmg_previewer_window.add_child(DmgPreviewerScene.instantiate())
		_dmg_previewer_window.close_requested.connect(
				_close_dmg_previewer_window)
		EditorInterface.popup_dialog_centered(_dmg_previewer_window)
	else:
		_dmg_previewer_window.grab_focus.call_deferred()


func _close_dmg_previewer_window() -> void:
	if _dmg_previewer_window:
		_dmg_previewer_window.queue_free()
	_dmg_previewer_window = null
