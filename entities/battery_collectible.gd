extends Area2D
class_name BatteryCollectible

@onready var sprite: Sprite2D = $Sprite2D

var ypos: float


func _ready() -> void:
	ypos = sprite.position.y
	Events.player_respawned.connect(player_respawned)
	

func _process(_delta: float) -> void:
	sprite.position.y = ypos + (sin(Time.get_ticks_msec() / 400.0) * 2)
	

func _on_body_entered(_body: Player) -> void:
	if self.visible:
		AudioManager.battery_collected_sfx.play()
		Events.emit_signal("battery_collected")
		self.hide()
	

func player_respawned() -> void:
	self.show()
	
