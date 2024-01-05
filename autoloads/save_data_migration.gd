class_name SaveDataMigration
extends RefCounted


func migrate(json: Dictionary) -> bool:
	var migrated: bool = false
	while json.version < SaveData.VERSION:
		# Match doesn't seem to recognize json.version as an int, therefore
		# I'm using an aux var to help it take the correct code path.
		var json_version: int = json.version
		match json_version:
			1:
				_migrate_to_v2(json)
				migrated = true
			2: 
				_migrate_to_v3(json)
				migrated = true
			_:
				print("Can't migrate to unknown save data version: ", json.version)
				break
	return migrated


func _migrate_to_v2(json: Dictionary) -> void:
	json["language"] = Utils.get_default_language()
	json["version"] = 2


func _migrate_to_v3(json: Dictionary) -> void:
	json["is_audio_enabled"] = true
	json["version"] = 3
