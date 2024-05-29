extends CanvasLayer
class_name LoadingScreen

signal loading_screen_has_full_coverage

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func start_outro_animation() -> void:
	animation_player.play("end_load")
	await animation_player.animation_finished
	self.queue_free()
	
