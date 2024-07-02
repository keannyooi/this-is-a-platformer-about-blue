extends Area2D
class_name PlatformButton

@export var linked_platform: ButtonPlatform

@onready var restart_cooldown_timer: Timer = $RestartCooldownTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	sprite.play("default")
	
	Events.player_respawned.connect(player_respawned)
	

func _on_body_entered(body: Player) -> void:
	sprite.play("pressed")
	self.set_deferred("monitoring", false)
	
	linked_platform.move()
	

func player_respawned() -> void:
	# this is to prevent the collectible from being picked up
	# when respawning at the area the collectible is in
	restart_cooldown_timer.start()
	await restart_cooldown_timer.timeout
	
	sprite.play("default")
	self.set_deferred("monitoring", true)
	
