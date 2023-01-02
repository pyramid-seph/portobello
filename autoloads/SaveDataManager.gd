extends Node

signal error_while_saving(error_msg)
signal saving_started
signal saving_finished


const SAVE_GAME_PATH: String = "user://save_data.json"

var save_data: SaveData

var _is_saving: bool = false


func _ready() -> void:
	reset_save_data()
	saving_started.connect(func(): _is_saving = true)
	saving_finished.connect(func(): _is_saving = false)
	_load()


func is_saving() -> bool:
	return _is_saving


func reset_save_data() -> void:
	save_data = SaveData.new()
	save()


func save() -> void:
	saving_started.emit()
	
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if not file:
		saving_finished.emit()
		_on_file_open_error()
		return
	
	if not save_data:
		save_data = SaveData.new()
	
	var json_string := JSON.stringify(save_data.to_dictionary())
	file.store_string(json_string)
	saving_finished.emit()


func _file_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)


func _ensure_file_exist() -> void:
	if not _file_exists():
		save_data = SaveData.new()
		save()


func _on_file_open_error() -> void:
	var error = FileAccess.get_open_error()
	var errorMsg := "Error while accesing save data: %s" % error
	error_while_saving.emit(errorMsg)


func _load() -> void:
	_ensure_file_exist()
	
	var file = FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if not file:
		_on_file_open_error()
		return
	
	var json_string := file.get_as_text()
	var data = JSON.parse_string(json_string)
