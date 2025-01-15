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
var landing_sfx_index: int = 0
var ceiling_sfx_index: int = 0


func _ready() -> void:
	# AudioServer bus layout setup
	AudioServer.set_bus_layout(bus_layout)
	

func play_landing_sfx(tilemap: TileMap, player_pos: Vector2) -> void:
	# update sfx if necessary
	# print(tilemap.local_to_map(player_pos))
	var tile_of_interest_coords: Vector2i = tilemap.local_to_map(player_pos)
	var offset_y: float = player_pos.y - tilemap.map_to_local(tile_of_interest_coords).y
	# print(offset_y)
	
	# check if the player is on one of those tiny slopes
	if round(offset_y) >= 0:
		# player is on tiny slope, apply y offset to tile to check
		tile_of_interest_coords.y += 1
	
	var floor_tile_data: TileData = tilemap.get_cell_tile_data(0, tile_of_interest_coords)
	# print(tile_of_interest_coords)
	if not floor_tile_data:
		# print(tile_of_interest_coords)
		# player is standing on ledge, check immediate surrounding blocks for tile data
		var offset_x: float = player_pos.x - tilemap.map_to_local(tile_of_interest_coords).x
		# print(offset_x)
		floor_tile_data = get_surrounding_tile_data(tile_of_interest_coords, offset_x, tilemap)
	
	# set landing sfx to index 0 in case no tile data can be found
	if floor_tile_data:
		landing_sfx_index = floor_tile_data.get_custom_data("LandingSFX")
	else:
		landing_sfx_index = 0
	
	# play the corresponding sfx afterwards
	player_landing_sfxs[landing_sfx_index].play()
	
	#player_landing_sfxs[landing_sfx_index].volume_db = remap(player.velocity.y, 0, 100, -20, 0)
	#player_landing_sfxs[landing_sfx_index].volume_db = clampf(player_landing_sfxs[landing_sfx_index].volume_db, -20, 0)
	

func play_ceiling_sfx(tilemap: TileMap, player_pos: Vector2) -> void:
	# update sfx if necessary
	var tile_of_interest_coords: Vector2i = tilemap.local_to_map(player_pos)
	var offset_y: float = player_pos.y - tilemap.map_to_local(tile_of_interest_coords).y
	print(offset_y)
	
	# check if the player is hitting one of those tiny slopes
	if round(offset_y) <= -3:
		# player is hitting tiny slope, apply y offset to tile to check
		tile_of_interest_coords.y -= 1
	
	print(tile_of_interest_coords)
	
	var ceiling_tile_data: TileData = tilemap.get_cell_tile_data(0, tile_of_interest_coords)
	if not ceiling_tile_data:
		var offset_x: float = player_pos.x - tilemap.map_to_local(tile_of_interest_coords).x
		# print(offset_x)
		ceiling_tile_data = get_surrounding_tile_data(tile_of_interest_coords, offset_x, tilemap)
	
	# set ceiling sfx to index 0 in case no tile data can be found
	if ceiling_tile_data:
		ceiling_sfx_index = ceiling_tile_data.get_custom_data("LandingSFX")
	else:
		ceiling_sfx_index = 0
	
	# play the corresponding sfx afterwards
	player_landing_sfxs[ceiling_sfx_index].play()
	

func get_surrounding_tile_data(tile_of_interest_coords: Vector2i, offset_x: float, tilemap: TileMap) -> TileData:
	# print(offset_x)
	if offset_x < -3:
		# the edge is to the right of the player
		tile_of_interest_coords += Vector2i(-1, 0)
	elif offset_x > 3:
		# the edge is to the left of the player
		tile_of_interest_coords += Vector2i(1, 0)
	
	return tilemap.get_cell_tile_data(0, tile_of_interest_coords)
	
