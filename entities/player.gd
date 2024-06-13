extends CharacterBody2D
class_name Player

const ACCEL: float = 75.0
const FLOAT_ACCEL: float = 75.0
const FRICTION: float = 200.0
const ENERGY_DRAIN_SPEED: float = 40.0
const MAX_ENERGY: int = 100

@onready var energy_bar: TextureProgressBar = $AnimatedSprite2D/EnergyBar
@onready var float_animation_timer: Timer = $FloatAnimationTimer
@onready var level_tilemap: TileMap = self.get_node("../TileMap")
@onready var recharge_cooldown_timer: Timer = $RechargeCooldownTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var alive: bool = true
var current_animation: String
var energy_depleted: bool = false
var energy: float = MAX_ENERGY
var float_animation_frame: int = 0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_forcing_movement: bool = false


func _ready() -> void:
	update_energy_bar()
	
	Events.level_complete.connect(force_movement)
	AudioManager.player_floating_sfx.play()
	

func _physics_process(delta: float) -> void:
	# currently these 2 variables are for handle_sfx() only
	# first check the player's surface touching conditions
	var was_on_floor = is_on_floor()
	var was_on_ceiling = is_on_ceiling()
	# all is_on_[surface]() type calls after this line reflect the
	# player's new surface touching conditions
	apply_gravity(delta)
	
	if not is_forcing_movement:
		# you shall not move on your own during the
		# section complete animation
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
	

func force_movement(direction: int, delta: float) -> void:
	# section complete animation where the player character
	# automatically moves itself out of the screen, then transitions
	# to the next section
	is_forcing_movement = true
	match direction:
		0: # LEFT
			self.velocity.x = move_toward(self.velocity.x, -ACCEL, ACCEL * 1.5 * delta)
		1: # RIGHT
			self.velocity.x = move_toward(self.velocity.x, ACCEL, ACCEL * 1.5 * delta)
		2: # UP
			self.velocity.y = move_toward(self.velocity.y, FLOAT_ACCEL * -1, FLOAT_ACCEL * 6 * delta)
		3: # DOWN
			pass
		_:
			push_error("ERROR: invalid direction")
	

func handle_float(delta: float) -> void:
	if Input.is_action_pressed("float") and energy > 0.0:
		self.velocity.y = move_toward(self.velocity.y, FLOAT_ACCEL * -1, FLOAT_ACCEL * 6 * delta)
		
		if recharge_cooldown_timer.time_left == 0.0:
			energy -= ENERGY_DRAIN_SPEED * delta
	

func handle_movement(input_axis: float, delta: float) -> void:
	if input_axis: # player's moving left or right
		self.velocity.x = move_toward(self.velocity.x, input_axis * ACCEL, ACCEL * 1.5 * delta)
		sprite.flip_h = input_axis < 0
	else: # player's not moving, will slow down and stop
		self.velocity.x = move_toward(self.velocity.x, 0, FRICTION * delta)
	

func handle_animation() -> void:
	# may redo this section later
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
		AudioManager.player_floating_sfx.volume_db = -5 # loud buzz
	else:
		AudioManager.player_floating_sfx.volume_db = -20 # quiet buzz
	
	# the game should make a noise when the player bumps either
	# the floor or the ceiling
	if not was_on_floor and is_on_floor():
		AudioManager.update_landing_sfx(level_tilemap, self)
		AudioManager.player_landing_sfxs[AudioManager.landing_sfx_index].play()
	if not was_on_ceiling and is_on_ceiling():
		AudioManager.update_landing_sfx(level_tilemap, self)
		AudioManager.player_landing_sfxs[AudioManager.ceiling_sfx_index].play()
	

func recharge_energy() -> void:
	energy = MAX_ENERGY
	energy_depleted = false
	# this timer is here to ensure the animation below transitions
	# smoothly between energy values
	# side effect: energy doesn't deplete during this period
	recharge_cooldown_timer.start()
	
	# lil refill animation for the battery hud above the player
	# hue value shifts from red (0) back to green (decimal value below)
	var tween = get_tree().create_tween().set_parallel(true)
	(tween.tween_property(energy_bar, "value", 100, recharge_cooldown_timer.wait_time)
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC))
	(tween.tween_property(energy_bar, "modulate:h", 0.35278, recharge_cooldown_timer.wait_time)
	.set_trans(Tween.TRANS_CUBIC))
	

func update_energy_bar() -> void:
	# hue value shifts from green (decimal value below) to red (0)
	energy_bar.value = energy
	energy_bar.modulate.h = remap(energy, 0, MAX_ENERGY, 0, 0.35278)
	

func _on_float_animation_timer_timeout() -> void:
	if Input.is_action_pressed("float") and energy > 0:
		float_animation_frame += 1
	else:
		float_animation_frame -= 1
	
	float_animation_frame = clamp(float_animation_frame, 0, 2)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# this node's here to automatically detect when the player leaves
	# this screen during the section complete animation
	# this way the game can transition to the next section more
	# smoothly and more reliably
	
	# filter out triggers from falling out of bounds during gameplay
	if not is_forcing_movement: return
	
	Events.player_left_screen_after_level_complete.emit()
	
