extends Area2D
class_name BatteryCollectible

@onready var restart_cooldown_timer: Timer = $RestartCooldownTimer
@onready var sprite: Sprite2D = $Sprite2D

var original_ypos: float


func _ready() -> void:
	original_ypos = sprite.position.y
	
	Events.player_respawned.connect(player_respawned)
	

func _process(_delta: float) -> void:
	# the collectible floats by going up and down in a sine wave
	sprite.position.y = original_ypos + (sin(Time.get_ticks_msec() / 400.0) * 2)
	

func _on_body_entered(_body: Player) -> void:
	# the collectible shouldn't detect any more collisions
	# after being collected
	self.set_deferred("monitoring", false)
	# the collectible marks its collection status based on
	# its visibility
	self.hide()
	
	AudioManager.battery_collected_sfx.play()
	Events.emit_signal("battery_collected")
	

func player_respawned() -> void:
	# this is to prevent the collectible from being picked up
	# when respawning at the area the collectible is in
	restart_cooldown_timer.start()
	await restart_cooldown_timer.timeout
	
	# the collectible can now be recollected
	self.set_deferred("monitoring", true)
	self.show()
	
