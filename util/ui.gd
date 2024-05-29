extends CanvasLayer
class_name UI

@onready var energy_bar: TextureProgressBar = $EnergyBar
@onready var percentage_label: Label = %PercentageLabel
@onready var timer_label: Label = %TimerLabel


func update_energy_bar(energy: float) -> void:
	energy_bar.value = energy
	percentage_label.text = str(roundf(abs(energy))) + "%"
	

func recharge_energy_bar() -> void:
	percentage_label.text = "100%"
	
	var tween = get_tree().create_tween()
	(tween.tween_property(energy_bar, "value", 100, 0.15)
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC))
	

func update_timer(time_msec: int) -> void:
	var minutes: int = floor(time_msec) / 60000
	var seconds: float = time_msec % 60000 / 1000.0
	
	timer_label.text = "{minutes}:{seconds}".format({
		"minutes": minutes,
		"seconds": "%06.3f" % seconds
	})
	
