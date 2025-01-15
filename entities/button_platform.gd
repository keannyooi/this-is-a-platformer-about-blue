extends StaticBody2D
class_name ButtonPlatform
enum MoveDirection { UP, DOWN, LEFT, RIGHT }

@export var move_tiles: int = 5
@export var direction: MoveDirection

@onready var sprite: Sprite2D = $Sprite2D
@onready var original_pos: Vector2i = self.position

const move_time: float = 0.75

var platform_tween: Tween


func _ready() -> void:
	# set the sprite to its deactivated state
	sprite.texture.region.position = Vector2.ZERO
	
	# move the platform back when the player respawns
	Events.player_respawned.connect(move_back)
	

func move() -> void:
	# set the sprite to its activated state
	sprite.texture.region.position = Vector2(0, 16)
	
	var move_px: int = move_tiles * 16
	platform_tween = (get_tree().create_tween()
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC))
	
	match direction:
		MoveDirection.UP:
			platform_tween.tween_property(self, "position:y", 
				self.position.y - move_px, move_time)
		MoveDirection.DOWN:
			platform_tween.tween_property(self, "position:y", 
				self.position.y + move_px, move_time)
		MoveDirection.LEFT:
			platform_tween.tween_property(self, "position:x", 
				self.position.x - move_px, move_time)
		MoveDirection.RIGHT:
			platform_tween.tween_property(self, "position:x", 
				self.position.x + move_px, move_time)
	

func move_back() -> void:
	# kill the tween before resetting position
	if platform_tween and platform_tween.is_running():
		platform_tween.kill()
	
	self.position = original_pos
	# set the sprite to its deactivated state
	sprite.texture.region.position = Vector2.ZERO
	
