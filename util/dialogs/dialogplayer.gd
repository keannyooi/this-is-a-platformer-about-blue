extends CanvasLayer
class_name DialogPlayer

signal dialog_complete()

@onready var dialog_section: Label = $DialogSection
@onready var dialog_timer: Timer = $DialogTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dialogs_file_path: String = "res://util/dialogs/dialogs.json"
var dialogs_dict: Dictionary

var dialog_key: String
var dialog_pointer: int = 0
var in_progress: bool = false


func _ready() -> void:
	# loading in dialogs.json file, where all dialogs are stored
	if not FileAccess.file_exists(dialogs_file_path):
		return push_error("ERROR: dialogs.json not found")

	var dialogs_file = FileAccess.open(dialogs_file_path, FileAccess.READ)
	dialogs_dict = JSON.parse_string(dialogs_file.get_as_text())
	
	# it will only show itself when triggered
	self.hide()
	

func display_dialog(dialog: Array) -> void:
	if dialog_pointer + 1 > dialog.size():
		# that's it. that's the end of the dialog
		animation_player.play("text_fade")
		await animation_player.animation_finished
		return end_dialog()
	
	print_debug("displaying line %d of dialog %s" % [dialog_pointer, dialog_key])
	if dialog_pointer > 0:
		# transitioning from previous line to the next
		animation_player.play("text_fade")
		await animation_player.animation_finished
	
	dialog_section.text = dialog[dialog_pointer]
	# ah yes, the opposite of fading out is fading in
	animation_player.play_backwards("text_fade")
	await animation_player.animation_finished
	

func end_dialog() -> void:
	in_progress = false
	dialog_pointer = 0
	dialog_timer.stop()
	animation_player.stop()
	self.hide()
	
	Events.dialog_complete.emit()
	

func start_dialog(key: String) -> void:
	if not key in dialogs_dict:
		push_error("ERROR: dialog key \"%s\" doesn't exist in dialogs.json"% key)
		return
	
	# storing the chosen dialog key internally for reference as the
	# dialog player progresses
	dialog_key = key
	# start automatically going through dialog text
	dialog_timer.start()
	in_progress = true
	display_dialog(dialogs_dict[dialog_key])
	self.show()
	

func _on_dialog_timer_timeout() -> void:
	# progress through dialog every (insert set amount of seconds)
	dialog_timer.start()
	dialog_pointer += 1
	display_dialog(dialogs_dict[dialog_key])
