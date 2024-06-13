extends Area2D
class_name MiniPopup
enum PopupType { READ, OBSERVE }

@export var active_area: CollisionShape2D
@export_multiline var popup_text: String = "placeholder text"
@export var hint_text: PopupType

@onready var hint_label: Label = %HintLabel
@onready var popup: VBoxContainer = $Popup
@onready var popup_label: Label = %PopupLabel
@onready var scroll_speed_timer: Timer = $ScrollSpeedTimer

var active: bool = false
var is_in_area: bool = false


func _ready() -> void:
	# initial text setup
	popup_label.text = popup_text
	match hint_text:
		PopupType.READ:
			hint_label.text = "[E] Read"
		PopupType.OBSERVE:
			hint_label.text = "[E] Observe"
		_:
			hint_label.text = "[E]"
	
	# it should be hidden until the player is in its general vicnity
	popup.hide()
	hint_label.hide()
	

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_action_pressed("interact")
	and not event.is_echo() and is_in_area):
		active = not active
		hint_label.visible = not hint_label.visible
		popup.visible = not popup.visible
		
		if active:
			popup_label.visible_characters = 0
			scroll_speed_timer.start()
	

func _on_body_entered(_body: Player) -> void:
	is_in_area = true
	hint_label.show()
	

func _on_body_exited(_body: Player) -> void:
	popup.hide()
	hint_label.hide()
	active = false
	is_in_area = false
	

func _on_scroll_speed_timer_timeout() -> void:
	# stop if the text has finished scrolling
	if popup_label.visible_ratio == 1 or not popup.visible: return
	
	popup_label.visible_characters += 1
	AudioManager.popup_scroll_text_sfx.play()
	scroll_speed_timer.start()
	
