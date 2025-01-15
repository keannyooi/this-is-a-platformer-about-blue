extends Button
class_name KeyRebindButton
enum InputEventType { MOVE_LEFT, MOVE_RIGHT, FLOAT, RESTART, INTERACT }

@export var input_action = InputEventType.MOVE_LEFT

@onready var input_action_string = input_action_strings[input_action]

var input_action_strings: Array[String] = [
	"move_left", "move_right", "float", "restart", "interact"
]

func _ready() -> void:
	# play hover sfx when focusing or hovering on any button
	# the reason why i did this instead of grabbing the focus is
	# because that would mess with input listening
	self.focus_entered.connect(AudioManager.button_hover_sfx.play)
	self.mouse_entered.connect(AudioManager.button_hover_sfx.play)
	
	# only process _unhandled_key_input when actually listening
	self.set_process_unhandled_key_input(false)
	

func button_default_status() -> void:
	# input_action_string = input_action_strings[input_action]
	
	# get current input event setup
	var event_array: Array[InputEvent] = InputMap.action_get_events(
		input_action_string
	)
	
	self.text = event_array[0].as_text_physical_keycode()
	# directly setting the pressed status
	# would trigger the input listening signal
	self.set_pressed_no_signal(false)
	self.set_process_unhandled_key_input(false)
	

func _on_toggled(_toggled_on: bool) -> void:
	self.text = "Listening input..."
	
	# how do you prevent the focus from moving during rebinding?
	# remove the focus entirely of course
	# this apporach also makes sre assigning keys to enter and space
	# doesn't trigger another input listening event
	self.release_focus()
	# time to listen
	self.set_process_unhandled_key_input(true)
	
	# this prevents the player from selecting multiple events to rebind
	for button in get_tree().get_nodes_in_group("key_rebind_buttons"):
		if button.input_action != input_action:
			button.button_default_status()
		
		button.focus_mode = FocusMode.FOCUS_NONE
	

func _unhandled_key_input(event: InputEvent) -> void:
	# filter out debounce
	if not event.pressed or event.is_echo(): return
	
	if not SettingsManager.is_duplicate_key(event):
		SettingsManager.rebind_key(input_action_string, event)
	else:
		self.text = "Can't set overlapping keybind"
		self.set_process_unhandled_key_input(false)
		await get_tree().create_timer(2.0).timeout
	
	button_default_status()
	
	# add the focus back, now that we're done with rebinding
	for button in get_tree().get_nodes_in_group("key_rebind_buttons"):
		button.focus_mode = FocusMode.FOCUS_ALL
	
	self.grab_focus()
	
