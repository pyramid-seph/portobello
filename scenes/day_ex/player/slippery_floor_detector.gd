extends Area2D


var _is_on_slippery_floor: bool


func is_on_slippery_floor() -> bool:
	return _is_on_slippery_floor


func _process_tile_map_collision(tile_map_layer: TileMapLayer, body_rid: RID) -> void:
	if not tile_map_layer:
		return
	
	var collided_tile_coords: Vector2i = \
			tile_map_layer.get_coords_for_body_rid(body_rid)
	var tile_data: TileData = \
			tile_map_layer.get_cell_tile_data(collided_tile_coords)
	if tile_data:
		_is_on_slippery_floor = tile_data.get_custom_data(
				Constants.RPG_TILEMAP_CUSTOM_DATA_LAYER_IS_SLIPPERY)


func _on_body_shape_entered(body_rid: RID, body: TileMapLayer, 
		_body_shape_index: int, _local_shape_index: int) -> void:
	_process_tile_map_collision(body, body_rid)
