extends CharacterBody2D


const SPEED = 180.0
const JUMP_VELOCITY = -450.0
const GRAVITY = 1800.0 # 1800 pixels per second squared


@onready var player = $"."
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var run_sound = $RunSound
@onready var jump_sound = $JumpSound

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	UpdateAnimation()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		# velocity.y += gravity * delta
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		# velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x = 0

	move_and_slide()

func UpdateAnimation():
	if velocity.x != 0:
		animated_sprite_2d.flip_h = velocity.x < 0

	if is_on_floor():
		if abs(velocity.x) > 0.1:
			animated_sprite_2d.play("run")
			if not run_sound.playing:
				run_sound.play()
		else:
			animated_sprite_2d.play("idle")
			run_sound.stop()
	else:
		animated_sprite_2d.play("jump")
		if not jump_sound.playing:
			jump_sound.play()
		run_sound.stop()
