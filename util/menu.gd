extends CanvasLayer
class_name Menu

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var settings_button: Button = %SettingsButton
@onready var transition_sprite: AnimatedSprite2D = %TransitionSprite


func _ready() -> void:
	transition_sprite.play("transition_in")
	AudioManager.tv_turnon_sfx.play()
	play_button.grab_focus()
	
	play_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	quit_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	settings_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	

func _on_play_button_pressed() -> void:
	if transition_sprite.is_playing(): return
	
	transition_sprite.play("transition_out")
	AudioManager.tv_shutdown_sfx.play()
	await transition_sprite.animation_finished
	
	LoadManager.load_scene("res://levels/level_1.tscn")
	

func _on_quit_button_pressed():
	transition_sprite.play("transition_out")
	AudioManager.tv_shutdown_sfx.play()
	await transition_sprite.animation_finished
	
	get_tree().quit()
	
