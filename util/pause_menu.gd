extends CanvasLayer
class_name PauseMenu
enum { PAUSE_TAB, SETTINGS, CONFIRM_TAB }

@onready var confirm_return_button: Button = %ConfirmReturnButton
@onready var continue_button: Button = %ContinueButton
@onready var deny_return_button: Button = %DenyReturnButton
@onready var return_button: Button = %ReturnButton
@onready var settings_button: Button = %SettingsButton
@onready var settings_container: SettingsContainer = %SettingsContainer
@onready var tab_container: TabContainer = $TabContainer
@onready var transition_sprite: AnimatedSprite2D = $Transition/TransitionSprite


func _ready() -> void:
	# initial setup
	connect_signals()
	
	transition_sprite.hide()
	self.hide() # pause menu hidden at first
	

func connect_signals() -> void:
	# play hover sfx when focusing on any button
	confirm_return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	continue_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	deny_return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	settings_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	
	# grab focus when the mouse is hovering over any button
	confirm_return_button.mouse_entered.connect(confirm_return_button.grab_focus)
	continue_button.mouse_entered.connect(continue_button.grab_focus)
	deny_return_button.mouse_entered.connect(deny_return_button.grab_focus)
	return_button.mouse_entered.connect(return_button.grab_focus)
	settings_button.mouse_entered.connect(settings_button.grab_focus)
	
	settings_container.settings_exit.connect(_on_deny_return_button_pressed)
	

func _notification(what: int) -> void:
	# pauses game when the game window is out of focus
	if (what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT
	and not get_tree().paused):
		pause_game()
	

func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel") 
	and not event.is_echo() and not get_tree().paused):
		pause_game()
	

func pause_game() -> void:
	get_tree().paused = true
	reset_pause_menu()
		
	self.show()
	

func reset_pause_menu() -> void:
	tab_container.current_tab = PAUSE_TAB # reset tab
	continue_button.grab_focus() # reset focus
	

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	self.hide()
	

func _on_return_button_pressed() -> void:
	tab_container.current_tab = CONFIRM_TAB
	deny_return_button.grab_focus()
	

func _on_confirm_return_button_pressed() -> void:
	# stop all ongoing bgm + sfx
	AudioManager.player_floating_sfx.stop()
	
	# transition out
	transition_sprite.show()
	transition_sprite.play("transition_out")
	AudioManager.tv_shutdown_sfx.play()
	await transition_sprite.animation_finished
	
	get_tree().paused = false # don't forget to unpause
	get_tree().change_scene_to_file("res://util/menu.tscn")
	

func _on_deny_return_button_pressed() -> void:
	reset_pause_menu()
	

func _on_settings_button_pressed() -> void:
	tab_container.current_tab = SETTINGS
	settings_container.settings_menu_setup(true)
	
