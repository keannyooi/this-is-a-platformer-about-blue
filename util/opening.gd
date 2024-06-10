extends Control
class_name Opening

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialog_player: DialogPlayer = $DialogPlayer
@onready var opening_ambience: AudioStreamPlayer = $OpeningAmbience


func _ready() -> void:
	Events.dialog_complete.connect(change_scene_to_menu)
	

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept") and not event.is_echo()
	and not animation_player.is_playing()):
		dialog_player.hide()
		change_scene_to_menu()
	

func change_scene_to_menu() -> void:
	animation_player.play("transition_menu")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_file("res://util/menu.tscn")
	
