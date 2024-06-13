extends VBoxContainer
class_name SettingsContainer

signal settings_exit

@onready var bgm_volume_slider: HScrollBar = %BGMVolumeSlider
@onready var return_button: Button = %ReturnButton
@onready var sections: TabContainer = $Sections
@onready var sfx_volume_slider: HScrollBar = %SFXVolumeSlider
@onready var slider_debounce_timer: Timer = $SliderDebounceTimer


func _ready() -> void:
	# play hover sfx when when focusing on any interactible control
	# node, including tabs
	bgm_volume_slider.focus_entered.connect(AudioManager.button_hover_sfx.play)
	sfx_volume_slider.focus_entered.connect(AudioManager.button_hover_sfx.play)
	return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	sections.tab_changed.connect(AudioManager.button_hover_sfx.play)
	
	# grab focus when the mouse cursor's hover over any interactible
	# control node
	bgm_volume_slider.mouse_entered.connect(bgm_volume_slider.grab_focus)
	sfx_volume_slider.mouse_entered.connect(sfx_volume_slider.grab_focus)
	return_button.mouse_entered.connect(return_button.grab_focus)
	

func _on_return_button_pressed() -> void:
	# saving into the settings config file, the game now remembers
	# your configs
	SettingsManager.save_settings()
	
	settings_exit.emit()
	

func settings_menu_setup(is_in_game: bool) -> void:
	print_debug("entering settings")
	bgm_volume_slider.grab_focus()
	
	bgm_volume_slider.value = SettingsManager.settings_dict["Audio"]["bgm_volume"]
	sfx_volume_slider.value = SettingsManager.settings_dict["Audio"]["sfx_volume"]
	
	if is_in_game:
		print_debug("currently in-game, unable to change speedrun timer setting")
		
	

func _on_bgm_volume_slider_value_changed(value: float) -> void:
	if not slider_debounce_timer.is_stopped(): return
	slider_debounce_timer.start()
	
	# print("bgm volume changed to %f" % value)
	SettingsManager.settings_dict["Audio"]["bgm_volume"] = value
	AudioServer.set_bus_volume_db(
		AudioManager.BusIndex.BGM, linear_to_db(value)
	)
	

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	if not slider_debounce_timer.is_stopped(): return
	slider_debounce_timer.start()
	
	# print("sfx volume changed to %f" % value)
	SettingsManager.settings_dict["Audio"]["sfx_volume"] = value
	AudioServer.set_bus_volume_db(
		AudioManager.BusIndex.SFX, linear_to_db(value)
	)
	
	# test how loud your sfxs are rn
	AudioManager.checkpoint_sfx.play()
	
