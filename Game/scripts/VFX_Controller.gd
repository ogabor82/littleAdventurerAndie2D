extends Node2D


@onready var animated_sprite_2d = $AnimatedSprite2D


func _ready():
	animated_sprite_2d.play("start")


func _process(_delta):
	if not animated_sprite_2d.is_playing():
		queue_free()
