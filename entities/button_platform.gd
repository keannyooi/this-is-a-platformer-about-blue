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
	sprite.texture.region.position = Vector2.ZERO
	
	Events.player_respawned.connect(move_back)
	

func move() -> void:
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
	if platform_tween and platform_tween.is_running():
		await platform_tween.finished
	
	self.position = original_pos
	sprite.texture.region.position = Vector2.ZERO
	
