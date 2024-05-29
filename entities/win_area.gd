extends Area2D
class_name Checkpoint

@onready var checkpoint_gradient: AnimatedSprite2D = $CheckpointGradient


func _on_body_entered(_body: Player):
	print_debug("checkpoint hit")
	Events.checkpoint_reached.emit(self)
	checkpoint_gradient.play("hit")
	AudioManager.checkpoint_sfx.play()
	
