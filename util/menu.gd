extends CanvasLayer
class_name Menu
enum { TITLE_SCREEN, SETTINGS }

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_container: SettingsContainer = %SettingsContainer
@onready var tab_container: TabContainer = $TabContainer
@onready var transition_sprite: AnimatedSprite2D = %TransitionSprite


func _ready() -> void:
	# menu setup in advance
	transition_sprite.show()
	play_button.grab_focus()
	connect_signals()
	
	# you can't select any buttons before the intro animation finishes playing
	transition_sprite.get_parent().mouse_filter = Control.MOUSE_FILTER_STOP
	
	transition_sprite.play("transition_in")
	AudioManager.tv_turnon_sfx.play()
	await transition_sprite.animation_finished
	
	# ok now you may select a button
	transition_sprite.get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
	

func connect_signals() -> void:
	# play hover sfx when focusing on any button
	play_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	quit_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	settings_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	
	# grab focus when the mouse cursor's hover over any button
	play_button.mouse_entered.connect(play_button.grab_focus)
	quit_button.mouse_entered.connect(quit_button.grab_focus)
	settings_button.mouse_entered.connect(settings_button.grab_focus)
	
	settings_container.settings_exit.connect(back_to_title_screen)
	

func back_to_title_screen() -> void:
	tab_container.current_tab = TITLE_SCREEN
	play_button.grab_focus()
	

func handle_transition_out_request() -> void:
	# you can't select any buttons before the intro animation finishes playing
	if transition_sprite.is_playing(): return
	
	# the play hover sfx shouldn't play after this
	# also doubles as manual cleanup i guess
	play_button.focus_entered.disconnect(AudioManager.button_hover_sfx.play)
	quit_button.focus_entered.disconnect(AudioManager.button_hover_sfx.play)
	settings_button.focus_entered.disconnect(AudioManager.button_hover_sfx.play)
	
	# transition out animation
	transition_sprite.play("transition_out")
	AudioManager.tv_shutdown_sfx.play()
	await transition_sprite.animation_finished
	

func _on_play_button_pressed() -> void:
	await handle_transition_out_request()
	
	LoadManager.load_scene("res://levels/level_1.tscn")
	

func _on_quit_button_pressed() -> void:
	await handle_transition_out_request()
	
	# see you next time
	get_tree().quit()
	

func _on_settings_button_pressed() -> void:
	# you can't select any buttons before the intro animation finishes playing
	if transition_sprite.is_playing(): return
	
	tab_container.current_tab = SETTINGS
	settings_container.settings_menu_setup(false)
	
