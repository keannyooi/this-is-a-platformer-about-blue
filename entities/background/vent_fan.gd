extends AnimatedSprite2D
class_name VentFan

@export var fan_speed: float = 0
@export_range (0, 3) var starting_frame: int = 0

func _ready() -> void:
	self.frame = starting_frame
	self.play("default", fan_speed, true)
	
