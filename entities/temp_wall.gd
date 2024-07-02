extends StaticBody2D
class_name TempWall

@onready var hitbox: CollisionShape2D = $Hitbox
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# restore wall when any of the 3 energy-refilling events happen
	Events.battery_collected.connect(restore_walls)
	Events.checkpoint_reached.connect(checkpoint_reached)
	Events.player_respawned.connect(restore_walls)
	
	# destroy wall when player energy runs out
	Events.player_energy_depleted.connect(player_energy_depleted)
	
	# initial state of wall
	sprite.play("default")
	

func checkpoint_reached(_checkpoint: Checkpoint) -> void:
	# this funtion only exists to stop the editor from printing
	# errors when running perfectly fine
	restore_walls()
	

func player_energy_depleted() -> void:
	# print_debug("player energy depleted, disabling collision")
	hitbox.set_deferred("disabled", true)
	sprite.play("destroyed")
	

func restore_walls() -> void:
	# print_debug("player energy restored, enabling collision")
	hitbox.set_deferred("disabled", false)
	sprite.play("restored")
	
