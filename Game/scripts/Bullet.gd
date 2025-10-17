extends Area2D


@onready var bullet_sprite_2d = $Bullet_Sprite2D


const SPEED = 500
var direction = 1
const DAMAGE = 35

func _physics_process(delta):
	if direction == -1:
		bullet_sprite_2d.flip_h = true
	
	position.x += direction * SPEED * delta


func _on_body_entered(_body):
	print("Bullet hit something")
	queue_free()
