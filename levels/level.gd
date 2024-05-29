extends Node2D

@export var level_id: int
@export var level_edge := Vector2i(10000, -10000)

@onready var dialog_player: DialogPlayer = $DialogPlayer
@onready var player: Player = $Player
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var ui: UI = $UI

var start_msec: int
var last_checkpoint: Dictionary = {
	"name": "WinArea0",
	"position": Vector2i(32, 168)
}
var level_completed: bool = false

func _ready() -> void:
	start_msec = Time.get_ticks_msec()
	player_camera.limit_right = level_edge.x
	player_camera.limit_top = level_edge.y
	
	Events.checkpoint_reached.connect(checkpoint_reached)
	Events.battery_collected.connect(battery_collected)
	
	# player.position = $Checkpoints/WinArea17.position
	

func _process(_delta: float) -> void:
	if level_completed == false && player.recharge_cooldown_timer.time_left == 0.0:
		ui.update_energy_bar(player.energy)
		player.update_energy_bar()
		ui.update_timer(Time.get_ticks_msec() - start_msec)
	

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and not event.is_echo():
		recharge_player_energy()
		respawn()
	

func checkpoint_reached(checkpoint: Checkpoint) -> void:
	var checkpoint_name = String(checkpoint.get_name())
	if checkpoint_name < last_checkpoint.name: return
	
	recharge_player_energy()
	if checkpoint_name == last_checkpoint.name: return
	
	last_checkpoint.name = checkpoint_name
	last_checkpoint.position = checkpoint.position
	
	match checkpoint_name:
		"WinArea1":
			dialog_player.start_dialog("section_1")
		"WinArea6":
			dialog_player.start_dialog("section_2")
		"WinArea10":
			dialog_player.start_dialog("section_3")
		"WinArea14":
			dialog_player.start_dialog("section_4")
		"WinArea17":
			dialog_player.start_dialog("section_5")
		_:
			pass
	

func battery_collected() -> void:
	recharge_player_energy()
	

func _on_out_of_bounds_area_body_entered(_body: Player) -> void:
	print_debug("player fell out of bounds, respawning")
	recharge_player_energy()
	respawn()
	

func recharge_player_energy() -> void:
	player.recharge_energy()
	ui.recharge_energy_bar()
	

func respawn() -> void:
	player.position = last_checkpoint.position
	player.velocity = Vector2.ZERO
	Events.player_respawned.emit()
	

func _on_next_area_teleport_body_entered(_body: Player) -> void:
	print_debug("level complete!")
	level_completed = true
	
	if level_id > 0:
		LoadManager.load_scene("res://levels/level_%d.tscn" % (level_id + 1))
	
