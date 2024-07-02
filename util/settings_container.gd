extends VBoxContainer
class_name SettingsContainer
enum SettingsTabs { AUDIO, GAMEPLAY, DISPLAY, CONTROLS }

signal settings_exit

@onready var bgm_volume_slider: HSlider = %BGMVolumeSlider
@onready var fullscreen_mode: CheckButton = %FullscreenMode
@onready var key_rebind_buttons: VBoxContainer = %KeyRebindButtons
@onready var return_button: Button = %ReturnButton
@onready var sections: TabContainer = $Sections
@onready var settings_tab_bar: TabBar = sections.get_tab_bar()
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var slider_debounce_timer: Timer = $SliderDebounceTimer


func _ready() -> void:
	# set default tab to first tab
	sections.current_tab = SettingsTabs.AUDIO
	
	connect_signals()
	

func connect_signals() -> void:
	# play hover sfx when when focusing on any interactible control
	# node, including tabs
	bgm_volume_slider.focus_entered.connect(AudioManager.button_hover_sfx.play)
	sfx_volume_slider.focus_entered.connect(AudioManager.button_hover_sfx.play)
	fullscreen_mode.focus_entered.connect(AudioManager.button_hover_sfx.play)
	return_button.focus_entered.connect(AudioManager.button_hover_sfx.play)
	sections.tab_changed.connect(AudioManager.button_hover_sfx.play)
	settings_tab_bar.focus_entered.connect(AudioManager.button_hover_sfx.play)
	
	# grab focus when the mouse cursor's hover over any interactible
	# control node
	bgm_volume_slider.mouse_entered.connect(bgm_volume_slider.grab_focus)
	sfx_volume_slider.mouse_entered.connect(sfx_volume_slider.grab_focus)
	fullscreen_mode.mouse_entered.connect(fullscreen_mode.grab_focus)
	return_button.mouse_entered.connect(return_button.grab_focus)
	settings_tab_bar.mouse_entered.connect(settings_tab_bar.grab_focus)
	
	# apparently you can't directly switch focus to the TabBar
	# inside the TabContainer so this line redirects the focus
	sections.focus_entered.connect(settings_tab_bar.grab_focus)
	

func settings_menu_setup(is_in_game: bool) -> void:
	print_debug("entering settings")
	sections.current_tab = SettingsTabs.AUDIO
	bgm_volume_slider.grab_focus()
	
	# display current settings values
	bgm_volume_slider.value = SettingsManager.settings_dict["Audio"]["bgm_volume"]
	sfx_volume_slider.value = SettingsManager.settings_dict["Audio"]["sfx_volume"]
	
	fullscreen_mode.button_pressed = SettingsManager.settings_dict["Display"]["fullscreen_mode"]
	
	if is_in_game:
		print_debug("currently in-game, unable to change speedrun timer setting")
		
	
	for button: KeyRebindButton in key_rebind_buttons.get_children():
		button.button_default_status()
	

func _on_bgm_volume_slider_value_changed(value: float) -> void:
	if not slider_debounce_timer.is_stopped(): return
	slider_debounce_timer.start()
	
	print("bgm volume changed to %f" % value)
	SettingsManager.set_volume(AudioManager.BusIndex.BGM, value)
	

func _on_fullscreen_mode_toggled(toggled_on: bool) -> void:
	SettingsManager.settings_dict["Display"]["fullscreen_mode"] = toggled_on
	
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# this line fixes a bug where the focus shifts to the tab bar
	# when entering fullscreen mode
	fullscreen_mode.grab_focus()
	

func _on_return_button_pressed() -> void:
	# saving into the settings config file, the game now remembers
	# your configs
	SettingsManager.save_settings()
	
	settings_exit.emit()
	

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	if not slider_debounce_timer.is_stopped(): return
	slider_debounce_timer.start()
	
	print("sfx volume changed to %f" % value)
	SettingsManager.set_volume(AudioManager.BusIndex.SFX, value)
	
	# test how loud your sfxs are rn
	AudioManager.checkpoint_sfx.play()
	
