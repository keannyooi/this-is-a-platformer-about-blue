extends Node
enum BusIndex { SFX = 1, BGM = 2 }
enum { TERRAIN_LEVELEDGE, TERRAIN_PUZZLE, TERRAIN_MATCHACHOCO }

# background

# gameplay
@onready var battery_collected_sfx: AudioStreamPlayer = $Gameplay/BatteryCollectedSFX
@onready var checkpoint_sfx: AudioStreamPlayer = $Gameplay/CheckpointSFX
@onready var player_floating_sfx: AudioStreamPlayer = $Gameplay/PlayerFloatingSFX
@onready var player_landing_sfxs: Array = $Gameplay/PlayerLandingSFXs.get_children()
@onready var popup_scroll_text_sfx: AudioStreamPlayer = $Gameplay/PopupScrollTextSFX
# ui
@onready var button_hover_sfx: AudioStreamPlayer = $UI/ButtonHoverSFX
@onready var tv_shutdown_sfx: AudioStreamPlayer = $UI/TVShutdownSFX
@onready var tv_turnon_sfx: AudioStreamPlayer = $UI/TVTurnonSFX

var bus_layout = load("res://default_bus_layout.tres")
var landing_sfx_dict: Dictionary = {
	TERRAIN_LEVELEDGE: 0,
	TERRAIN_PUZZLE: 1,
	TERRAIN_MATCHACHOCO: 1
}
var landing_sfx_index: int = landing_sfx_dict[TERRAIN_LEVELEDGE]
var ceiling_sfx_index: int = landing_sfx_dict[TERRAIN_LEVELEDGE]


func _ready() -> void:
	# AudioServer bus layout setup
	AudioServer.set_bus_layout(bus_layout)
	

func update_landing_sfx(tilemap: TileMap, player: Player):
	var tile_of_interest_coords: Vector2i = tilemap.local_to_map(player.global_position)
	var floor_tile_data: TileData = tilemap.get_cell_tile_data(0, tile_of_interest_coords + Vector2i(0, 3))
	var ceiling_tile_data: TileData = tilemap.get_cell_tile_data(0, tile_of_interest_coords + Vector2i(0, 1))
	
	if floor_tile_data:
		var terrainId: int = absi(floor_tile_data.terrain)
		landing_sfx_index = landing_sfx_dict[terrainId]
	if ceiling_tile_data:
		var terrainId: int = absi(ceiling_tile_data.terrain)
		ceiling_sfx_index = landing_sfx_dict[terrainId]
	
	#player_landing_sfxs[landing_sfx_index].volume_db = remap(player.velocity.y, 0, 100, -20, 0)
	#player_landing_sfxs[landing_sfx_index].volume_db = clampf(player_landing_sfxs[landing_sfx_index].volume_db, -20, 0)
	
