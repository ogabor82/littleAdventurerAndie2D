extends Area2D
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var value = 1

func _on_body_entered(body):
	animated_sprite_2d.play("collected")
	var player = body as PlayerController
	if player:
		player.CollectCoin(value)


func _process(_delta):
	if animated_sprite_2d.is_playing() == false:
		queue_free()