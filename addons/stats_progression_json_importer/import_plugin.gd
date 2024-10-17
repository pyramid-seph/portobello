@tool
extends EditorImportPlugin


const StatsProgressionParser = preload("res://addons/stats_progression_json_importer/stats_progression_parser.gd")


func _get_importer_name():
	return "bucho_portobello.stats_progression_json_importer"


func _get_visible_name() -> String:
	return "Stats Progression Curves"


func _get_recognized_extensions():
	return ["stats"]


func _get_save_extension() -> String:
	return "tres"


func _get_resource_type() -> String:
	return "Resource"


func _get_preset_count() -> int:
	return 0


func _get_import_options(_path: String, _preset_index: int) -> Array[Dictionary]:
	return []


func _get_priority() -> float:
	return 1.0


func _get_import_order() -> int:
	return IMPORT_ORDER_DEFAULT


func _import(
		source_file: String, 
		save_path: String, 
		options: Dictionary, 
		platform_variants: Array[String], 
		gen_files: Array[String]) -> Error:
	var file := FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	var json_text: String = file.get_as_text()
	var parse_result: StatsProgressionParser.Result = \
			StatsProgressionParser.parse_json_text(json_text)
	if parse_result.is_ok():
		return ResourceSaver.save(parse_result.object,
				"%s.%s" % [save_path, _get_save_extension()])
	else:
		return parse_result.error
