extends Node

signal error_while_saving(error_msg)
signal saving_started
signal saving_finished


const SAVE_GAME_PATH: String = "user://save_data.json"

var save_data: SaveData

var _is_saving: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	_load()


func is_saving() -> bool:
	return _is_saving


func reset_save_data() -> void:
	save_data = SaveData.new()
	save()


func save() -> void:
	_is_saving = true
	saving_started.emit()
	
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if not file:
		_is_saving = false
		saving_finished.emit()
		_on_file_open_error()
		return
	
	if not save_data:
		save_data = SaveData.new()
	
	var json_string: String = JSON.stringify(save_data.to_dictionary())
	file.store_string(json_string)
	_is_saving = false
	saving_finished.emit()


func _file_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)


func _ensure_file_exist() -> void:
	if not _file_exists():
		save_data = SaveData.new()
		save()


func _on_file_open_error() -> void:
	var error := FileAccess.get_open_error()
	var errorMsg := tr("LOAD_SAVE_DATA_ERROR").format({ error_message = error })
	error_while_saving.emit(errorMsg)


func _load() -> void:
	_ensure_file_exist()
	
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if not file:
		_on_file_open_error()
		return
	
	var json_string: String = file.get_as_text()
	var data = JSON.parse_string(json_string)
	if data:
		var migrated = SaveDataMigration.new().migrate(data)
		save_data = SaveData.from_json(data)
		if migrated:
			save()
	else: # Got an error while parsing the json.
		reset_save_data()
