class_name Constants
extends RefCounted

const LAYER_NONE: int = 0
const LAYER_HURTBOX: int = 1
const LAYER_HITBOX: int = 2
const LAYER_PICKUP: int = 4
const LAYER_PLAYER_BULLETS: int = 8
const LAYER_ENEMY_BULLETS: int = 16
const LAYER_PLAYER: int = 32
const LAYER_ENEMY: int = 64
const LAYER_SOLID_TILE: int = 128
const LAYER_EXIT: int = 256
const LAYER_ACTION_AREA: int = 512
const LAYER_TERRAIN: int = 1024

const GROUP_PLAYERS: String = "players"
const GROUP_ENEMIES: String = "enemies"

const RPG_TILEMAP_LAYER_IDX_FLOOR: int = 0
const RPG_TILEMAP_LAYER_IDX_BATTLE_CONFIG: int = 2

const RPG_TILEMAP_CUSTOM_DATA_LAYER_RANDOM_BATTLE_ID: String = "random_battle_id"
const RPG_TILEMAP_CUSTOM_DATA_LAYER_IS_SLIPPERY: String = "is_slippery"
