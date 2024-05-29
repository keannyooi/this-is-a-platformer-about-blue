extends CharacterBody2D
class_name Player

const accel: float = 75.0
const float_accel: float = 75.0
const friction: float = 200.0
const energy_drain_speed: float = 40.0
const maximum_energy: int = 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var float_animation_timer: Timer = $FloatAnimationTimer
@onready var recharge_cooldown_timer: Timer = $RechargeCooldownTimer
@onready var energy_bar: TextureProgressBar = $AnimatedSprite2D/EnergyBar
@onready var level_tilemap: TileMap = self.get_node("../TileMap")

var alive: bool = true
var current_animation: String
var energy_depleted: bool = false
var energy: float = maximum_energy
var float_animation_frame: int = 0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	update_energy_bar()
	
	AudioManager.player_floating_sfx.play()
	

func _physics_process(delta: float) -> void:
	var was_on_floor = is_on_floor()
	var was_on_ceiling = is_on_ceiling()
	apply_gravity(delta)
	handle_float(delta)
	
	var input_axis: float = Input.get_axis("move_left", "move_right")
	handle_movement(input_axis, delta)

	move_and_slide()
	handle_animation()
	handle_sfx(was_on_floor, was_on_ceiling)
	
	if energy <= 0 and not energy_depleted:
		Events.player_energy_depleted.emit()
		energy_depleted = true
	

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		self.velocity.y += gravity * delta
	

func handle_float(delta: float) -> void:	
	if Input.is_action_pressed("float") and energy > 0.0:
		self.velocity.y = move_toward(self.velocity.y, float_accel * -1, float_accel * 6 * delta)
		
		if recharge_cooldown_timer.time_left == 0.0:
			energy -= energy_drain_speed * delta
	

func handle_movement(input_axis: float, delta: float) -> void:
	if input_axis:
		self.velocity.x = move_toward(self.velocity.x, input_axis * accel, accel * 1.5 * delta)
		sprite.flip_h = input_axis < 0
	else:
		self.velocity.x = move_toward(self.velocity.x, 0, friction * delta)
	

func handle_animation() -> void:
	if not alive:
		current_animation = "dead"
	elif Input.is_action_pressed("float") and energy > 0:
		current_animation = "float"
	elif velocity == Vector2.ZERO:
		current_animation = "idle"
	elif self.velocity.y > 0:
		current_animation = "fall"
	else:
		current_animation = "move"
	
	sprite.play(current_animation)
	if current_animation == "float" or current_animation == "fall":
		sprite.frame = float_animation_frame
	

func handle_sfx(was_on_floor: bool, was_on_ceiling: bool) -> void:
	if Input.is_action_pressed("float") and energy > 0.0:
		if AudioManager.player_floating_sfx.volume_db != 0:
			AudioManager.player_floating_sfx.volume_db = 0
	elif AudioManager.player_floating_sfx.volume_db == 0:
		AudioManager.player_floating_sfx.volume_db = -15
	
	AudioManager.update_landing_sfx(level_tilemap, self)
	if not was_on_floor and is_on_floor():
		AudioManager.player_landing_sfxs[AudioManager.landing_sfx_index].play()
	if not was_on_ceiling and is_on_ceiling():
		AudioManager.player_landing_sfxs[AudioManager.ceiling_sfx_index].play()
	

func recharge_energy() -> void:
	recharge_cooldown_timer.start()
	energy = maximum_energy
	energy_depleted = false
	
	var tween = get_tree().create_tween()
	(tween.tween_property(energy_bar, "value", 100, 0.15)
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC))
	

func update_energy_bar() -> void:
	energy_bar.value = energy
	

func _on_float_animation_timer_timeout() -> void:
	if Input.is_action_pressed("float") and energy > 0:
		float_animation_frame += 1
	else:
		float_animation_frame -= 1
	
	float_animation_frame = clamp(float_animation_frame, 0, 2)
