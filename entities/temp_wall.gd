extends StaticBody2D
class_name TempWall

@onready var hitbox: CollisionShape2D = $Hitbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	Events.checkpoint_reached.connect(checkpoint_reached)
	Events.player_respawned.connect(player_respawned)
	Events.player_energy_depleted.connect(player_energy_depleted)
	Events.battery_collected.connect(battery_collected)
	
	sprite.play("default")
	

func player_energy_depleted() -> void:
	# print_debug("player energy depleted, disabling collision")
	hitbox.set_deferred("disabled", true)
	sprite.play("destroyed")
	

func battery_collected() -> void:
	restore_walls()
	

func checkpoint_reached(_checkpoint: Checkpoint) -> void:
	restore_walls()
	

func player_respawned() -> void:
	restore_walls()
	

func restore_walls() -> void:
	# print_debug("player energy restored, enabling collision")
	hitbox.set_deferred("disabled", false)
	sprite.play("restored")
	
