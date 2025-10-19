extends CharacterBody2D
class_name PlayerController


const SPEED = 180.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 1800.0 # 1800 pixels per second squared


@onready var player = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shooting_point = $Shooting_Point

@onready var run_sound = $RunSound
@onready var jump_sound = $JumpSound

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var AirborneLastFrame = false

var isShooting = false
const SHOOT_DURATION = 0.249

enum PlayerState {
	Normal, Hurt, Dead
}

var currentState: PlayerState = PlayerState.Normal:
	set(new_value):
		currentState = new_value
		match currentState:
			PlayerState.Normal:
				pass
			PlayerState.Hurt:
				if is_on_floor():
					animated_sprite_2d.play("hit_stand")
				else:
					animated_sprite_2d.play("hit_jump")
			PlayerState.Dead:
				animated_sprite_2d.play("die")
				set_collision_layer_value(2, false)

var currentHealth:
	set(new_value):
		currentHealth = new_value
		emit_signal("playerHealthUpdated", currentHealth, MAX_HEALTH)
const MAX_HEALTH = 100

signal playerHealthUpdated(newValue: int, maxValue: int)

func _ready():
	currentHealth = MAX_HEALTH
	GameManager.player = self
	GameManager.playerOriginalPos = position

func _process(_delta):
	UpdateAnimation()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		# velocity.y += gravity * delta
		velocity.y += GRAVITY * delta
		AirborneLastFrame = true
	elif AirborneLastFrame:
		PlayLandVFX()
		AirborneLastFrame = false

	if currentState == PlayerState.Hurt or currentState == PlayerState.Dead:
		velocity.x = 0
		move_and_slide()
		return

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		PlayJumpUpVFX()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		# velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x = 0

	if Input.is_action_just_pressed("Shoot"):
		TryToShoot()

	if Input.is_action_just_pressed("Down") and is_on_floor():
		position.y += 3

	move_and_slide()

func UpdateAnimation():
	if currentState == PlayerState.Dead:
		return
	elif currentState == PlayerState.Hurt:
		if animated_sprite_2d.is_playing():
			return
		else:
			currentState = PlayerState.Normal

	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0
		if velocity.x < 0:
			shooting_point.position.x = -26
		else:
			shooting_point.position.x = 26

	if is_on_floor():
		if abs(velocity.x) > 0.1:
			var playingAnimationFrame = animated_sprite_2d.frame
			var playingAnimationName = animated_sprite_2d.animation

			if isShooting:
				animated_sprite_2d.play("shoot_run")

				if playingAnimationName == "run":
					animated_sprite_2d.frame = playingAnimationFrame
			else:
				if playingAnimationName == "shoot_run" and animated_sprite_2d.is_playing():
					pass
				else:
					animated_sprite_2d.play("run")
			if not run_sound.playing:
				run_sound.play()
		else:
			if isShooting:
				animated_sprite_2d.play("shoot_stand")
			else:
				animated_sprite_2d.play("idle")
			run_sound.stop()
	else:
		animated_sprite_2d.play("jump")
		if not jump_sound.playing:
			jump_sound.play()
		run_sound.stop()

		if isShooting:
			animated_sprite_2d.play("shoot_jump")


func PlayJumpUpVFX():
	var vfxToSpawn = preload("res://Game/scenes/vfx_jump_up.tscn")
	GameManager.SpawnVFX(vfxToSpawn, global_position)


func PlayLandVFX():
	var vfxToSpawn = preload("res://Game/scenes/vfx_land.tscn")
	GameManager.SpawnVFX(vfxToSpawn, global_position)

func Shoot():
	var bulletToSpawn = preload("res://Game/scenes/bullet.tscn")
	var bulletInstance = GameManager.SpawnVFX(bulletToSpawn, shooting_point.global_position)
	
	if animated_sprite_2d.flip_h:
		bulletInstance.direction = -1
	else:
		bulletInstance.direction = 1


func TryToShoot():
	if isShooting:
		return

	isShooting = true
	Shoot()
	PlayFireVFX()
	await get_tree().create_timer(SHOOT_DURATION).timeout
	isShooting = false

func PlayFireVFX():
	var vfxToSpawn = preload("res://Game/scenes/vfx_player_fire.tscn")
	var vfxInstance = GameManager.SpawnVFX(vfxToSpawn, shooting_point.global_position)

	if animated_sprite_2d.flip_h:
		vfxInstance.scale.x = -1
	else:
		vfxInstance.scale.x = 1


func ApplyDamage(damage: int):
	if currentState == PlayerState.Dead or currentState == PlayerState.Hurt:
		return

	currentHealth -= damage
	currentState = PlayerState.Hurt

	if currentHealth <= 0:
		currentHealth = 0
		currentState = PlayerState.Dead
