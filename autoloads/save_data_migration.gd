class_name SaveDataMigration
extends RefCounted


func migrate(json: Dictionary) -> void:
	while json.version < SaveData.VERSION:
		match json.version:
			1:
				_migrate_to_v2(json)
			_:
				print("Cannot migrate to an unknown version")
				break


func _migrate_to_v2(json: Dictionary) -> void:
	json["language"] = Utils.get_default_language()
	json["version"] = 2
