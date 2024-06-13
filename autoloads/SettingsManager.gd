extends Node

const SETTINGS_FILE_PATH: String = "user://settings.cfg"

var settings_file = ConfigFile.new()
var settings_dict: Dictionary = {
	"Audio": {
		"bgm_volume": 0.5,
		"sfx_volume": 0.5
	},
	"Gameplay": {
		"speedrun_timer_enabled": false
	},
	"Controls": {
		
	}
}

func _ready() -> void:
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		print("settings config file exists, attempting to load")
		
		var settings_file_load_status = settings_file.load(SETTINGS_FILE_PATH)
		if settings_file_load_status == OK:
			load_settings()
			
			return print("settings config file successfully loaded")
		else:
			return push_error("ERROR: settings config file failed to load in")
	
	print("settings config file not found at specified file path, creating new file")
	
	save_settings()
	

func save_settings() -> void:
	for section in settings_dict:
		for setting in settings_dict[section]:
			settings_file.set_value(
				section,
				setting,
				settings_dict[section][setting]
			)
	
	settings_file.save(SETTINGS_FILE_PATH)
	

func load_settings() -> Dictionary:
	# updating the settings dictionary to reflect the values stored
	# in the config file
	for section in settings_dict:
		for setting in settings_dict[section]:
			settings_dict[section][setting] = settings_file.get_value(
				section, setting
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
	
	return settings_dict
	
