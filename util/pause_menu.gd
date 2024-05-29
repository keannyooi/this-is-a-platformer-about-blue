extends CanvasLayer
class_name PauseMenu

@onready var confirm_return_button: Button = %ConfirmReturnButton
@onready var continue_button: Button = %ContinueButton
@onready var deny_return_button: Button = %DenyReturnButton
@onready var return_button: Button = %ReturnButton
@onready var tab_container: TabContainer = $TabContainer
@onready var transition_sprite: AnimatedSprite2D = %TransitionSprite

enum { PAUSE_TAB, CONFIRM_TAB }


func _ready() -> void:
	hide()
	tab_container.current_tab = PAUSE_TAB
	
	confirm_return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	continue_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	deny_return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo() and not get_tree().paused:
		continue_button.grab_focus()
		get_tree().paused = true
		tab_container.current_tab = PAUSE_TAB
		show()
	

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	hide()
	

func _on_return_button_pressed() -> void:
	tab_container.current_tab = CONFIRM_TAB
	deny_return_button.grab_focus()
	

func _on_confirm_return_button_pressed() -> void:
	transition_sprite.show()
	transition_sprite.play("transition_out")
	AudioManager.tv_shutdown_sfx.play()
	await transition_sprite.animation_finished
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://util/menu.tscn")
	

func _on_deny_return_button_pressed() -> void:
	tab_container.current_tab = PAUSE_TAB
	continue_button.grab_focus()
	
