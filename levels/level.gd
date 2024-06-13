extends Node2D
class_name Level
enum LevelCompleteDirection { LEFT, RIGHT, UP, DOWN }

@export var level_id: int
@export var level_edge := Vector2i(10000, -10000)
@export var level_complete_direction: LevelCompleteDirection

@onready var dialog_player: DialogPlayer = $DialogPlayer
@onready var player: Player = $Player
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var ui: UI = $UI

var dialog_key_dict: Dictionary = {
	1.0: "section_1",
	5.0: "section_2",
	10.0: "section_3",
	15.0: "section_4",
	20.0: "section_5",
	25.0: "section_6"
}
var is_level_completed: bool = false
var last_checkpoint: Dictionary = {
	"id": 0.0,
	"position": Vector2i(32, 168) # spawn point
}
var start_msec: int


func _ready() -> void:
	# initializing player camera limits
	player_camera.limit_right = level_edge.x
	player_camera.limit_top = level_edge.y
	
	# speedrun timer, will update code when it's actually in
	start_msec = Time.get_ticks_msec()
	 
	Events.checkpoint_reached.connect(checkpoint_reached)
	# recharge energy when battery collectible is collected
	Events.battery_collected.connect(recharge_player_energy)
	
	# this line is for level testing purposes
	# player.position = $Checkpoints/WinArea9.position
	

func _process(_delta: float) -> void:
	if not is_level_completed:
		if player.recharge_cooldown_timer.time_left == 0.0:
			# energy bar ui updating
			ui.update_energy_bar(player.energy)
			player.update_energy_bar()
		
		# speedrun timer, will update code when it's actually in
		ui.update_timer(Time.get_ticks_msec() - start_msec)
	

func _physics_process(delta: float) -> void:
	if is_level_completed:
		player.force_movement(level_complete_direction, delta)
	

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("restart") and not event.is_echo()
	and not is_level_completed):
		recharge_player_energy()
		respawn()
	

func checkpoint_reached(checkpoint: Checkpoint) -> void:
	recharge_player_energy()
	
	# only store a new checkpoint if the checkpoint comes after the
	# original
	if checkpoint.id <= last_checkpoint.id: return
	
	last_checkpoint.id = checkpoint.id
	last_checkpoint.position = checkpoint.position
	
	# only play dialog if the current checkpoint's id is inside
	# the dialog key dictionary
	if checkpoint.id not in dialog_key_dict: return
	dialog_player.start_dialog(dialog_key_dict[checkpoint.id])
	

func _on_out_of_bounds_area_body_entered(_body: Player) -> void:
	print_debug("player fell out of bounds, respawning")
	recharge_player_energy()
	respawn()
	

func recharge_player_energy() -> void:
	player.recharge_energy()
	ui.display_energy_recharge()
	

func respawn() -> void:
	player.position = last_checkpoint.position
	# this is to prevent the player from flying off from residual
	# velocity when resetting
	player.velocity = Vector2.ZERO
	
	Events.player_respawned.emit()
	

func _on_next_area_teleport_body_entered(_body: Player) -> void:
	print_debug("level complete!")
	is_level_completed = true
	Events.level_complete.emit(level_complete_direction)
	
	await Events.player_left_screen_after_level_complete
	
	if level_id > 0:
		LoadManager.load_scene("res://levels/level_%d.tscn" % (level_id + 1))
	
