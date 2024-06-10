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
	popup.hide()
	hint_label.hide()
	
	popup_label.text = popup_text
	match hint_text:
		PopupType.READ:
			hint_label.text = "[Q] Read"
		PopupType.OBSERVE:
			hint_label.text = "[Q] Observe"
		_:
			hint_label.text = "[Q]"
	

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.is_action_pressed("open_popup")
	and not event.is_echo() and is_in_area):
		active = not active
		if active:
			hint_label.hide()
			popup.show()
			
			popup_label.visible_characters = 0
			scroll_speed_timer.start()
		else:
			hint_label.show()
			popup.hide()
	

func _on_body_entered(_body: Player) -> void:
	hint_label.show()
	is_in_area = true
	

func _on_body_exited(_body: Player) -> void:
	is_in_area = false
	if active:
		popup.hide()
		active = false
	
	hint_label.hide()
	

func _on_scroll_speed_timer_timeout() -> void:
	if popup_label.visible_ratio == 1 or not popup.visible: return
	
	popup_label.visible_characters += 1
	AudioManager.popup_scroll_text_sfx.play()
	scroll_speed_timer.start()
	
