extends CanvasLayer
class_name UI

@onready var energy_bar: TextureProgressBar = %EnergyBar
@onready var low_energy_flash_timer: Timer = $LowEnergyFlashTimer
@onready var percentage_label: Label = %PercentageLabel
@onready var timer_label: Label = %TimerLabel

const LOW_ENERGY_THRESHOLD: float = 25.0
var is_energy_low: bool = false


func display_energy_recharge() -> void:
	is_energy_low = false
	percentage_label.modulate.a = 255
	
	var tween = get_tree().create_tween().set_parallel(true)
	(tween.tween_property(energy_bar, "value", 100, 0.15)
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC))
	(tween.tween_property(energy_bar, "self_modulate:h", 0.35278, 0.15)
	.set_trans(Tween.TRANS_LINEAR))
	

func update_energy_bar(energy: float) -> void:
	energy_bar.value = energy
	energy_bar.self_modulate.h = remap(energy, 0, 100, 0, 0.35278)
	percentage_label.text = str(roundf(abs(energy))) + "%"
	
	if (energy_bar.value > LOW_ENERGY_THRESHOLD
	and percentage_label.modulate.a == 0):
		# this fixes a bug where recharging at a really specific timing
		# causes the percentage label to disappear
		percentage_label.modulate.a = 255
	
	if energy <= LOW_ENERGY_THRESHOLD and not is_energy_low:
		is_energy_low = true
		low_energy_flash_timer.start()
	

func update_timer(time_msec: int) -> void:
	var minutes: int = floor(time_msec) / 60000
	var seconds: float = time_msec % 60000 / 1000.0
	
	timer_label.text = "{minutes}:{seconds}".format({
		"minutes": minutes,
		"seconds": "%06.3f" % seconds
	})
	

func _on_low_energy_flash_timer_timeout() -> void:
	if energy_bar.value > LOW_ENERGY_THRESHOLD: return
	
	if percentage_label.modulate.a == 255:
		percentage_label.modulate.a = 0
	else:
		percentage_label.modulate.a = 255
	
	low_energy_flash_timer.start()
	
