extends Area2D
class_name BatteryCollectible

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var original_ypos: float


func _ready() -> void:
	original_ypos = sprite.position.y
	
	Events.player_respawned.connect(player_respawned)
	

func _process(_delta: float) -> void:
	# the collectible floats by going up and down in a sine wave
	sprite.position.y = original_ypos + (sin(Time.get_ticks_msec() / 400.0) * 2)
	

func _on_body_entered(_body: Player) -> void:
	# the collectible marks its collection status based on
	# its visibility
	if self.visible:
		self.hide()
		# the collectible shouldn't detect any more collisions
		# after being collected
		collision_shape.set_deferred("disabled", true)
		
		AudioManager.battery_collected_sfx.play()
		Events.emit_signal("battery_collected")
	

func player_respawned() -> void:
	# the collectible can now be recollected
	self.show()
	collision_shape.set_deferred("disabled", false)
	
