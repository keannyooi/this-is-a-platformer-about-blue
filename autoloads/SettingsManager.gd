extends Node

const SETTINGS_FILE_PATH: String = "user://settings.cfg"

@onready var keybinds_resource: KeybindsResource = preload("res://resources/keybinds/DefaultKeybinds.tres")

var settings_file = ConfigFile.new()
var settings_dict: Dictionary = {
	"Audio": {
		"bgm_volume": 0.5,
		"sfx_volume": 0.5
	},
	"Gameplay": {
		"speedrun_timer_enabled": false
	},
	"Display": {
		"fullscreen_mode": false
	},
	"Controls": {
		"move_left": Key.KEY_A,
		"move_right": Key.KEY_D,
		"float": Key.KEY_W,
		"restart": Key.KEY_R,
		"interact": Key.KEY_E
	}
}


func _ready() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		print("settings config file not found at specified file path, creating new file")
		save_settings()
	
	print("loading settings config file...")
		
	var settings_file_load_status = settings_file.load(SETTINGS_FILE_PATH)
	if settings_file_load_status == OK:
		load_settings()
			
		return print("settings config file successfully loaded")
	else:
		return push_error("ERROR: settings config file failed to load in")
	

func is_duplicate_key(event: InputEvent) -> bool:
	var keycodes: Array = settings_dict["Controls"].values()
	print(settings_dict["Controls"])
	print(event.physical_keycode)
	# if this returns anything but -1, it's a dupe
	return keycodes.find(event.physical_keycode) > -1
	

func load_settings() -> Dictionary:
	# updating the settings dictionary to reflect the values stored
	# in the config file
	for section in settings_dict:
		for setting in settings_dict[section]:
			settings_dict[section][setting] = settings_file.get_value(
				section, setting, settings_dict[section][setting]
			)
	
	# actually apply the audio settings
	AudioServer.set_bus_volume_db(
		AudioManager.BusIndex.BGM,
		linear_to_db(settings_dict["Audio"]["bgm_volume"])
	)
	AudioServer.set_bus_volume_db(
		AudioManager.BusIndex.SFX,
		linear_to_db(settings_dict["Audio"]["sfx_volume"])
	)
	
	# actually apply the display settings
	if settings_dict["Display"]["fullscreen_mode"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# actually apply the keybinds
	for action in settings_dict["Controls"]:
		var event = InputEventKey.new()
		event.physical_keycode = settings_dict["Controls"][action]
		InputMap.action_add_event(action, event)
	
	return settings_dict
	

func rebind_key(input_action: String, event: InputEventKey) -> void:
	SettingsManager.settings_dict["Controls"][input_action] = event.physical_keycode
	
	InputMap.action_erase_events(input_action)
	InputMap.action_add_event(input_action, event)
	

func save_settings() -> void:
	for section in settings_dict:
		for setting in settings_dict[section]:
			settings_file.set_value(
				section,
				setting,
				settings_dict[section][setting]
			)
	
	settings_file.save(SETTINGS_FILE_PATH)
	

func set_volume(bus_index: int, value: float) -> void:
	# lil sanity check
	const bus_strings: Array[StringName] = ["sfx", "bgm"]
	if bus_index != 1 and bus_index != 2:
		return push_error("ERROR: bus specified not found")
	
	settings_dict["Audio"]["%s_volume" % bus_strings[bus_index - 1]] = value
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	
