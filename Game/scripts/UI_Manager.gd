extends CanvasLayer

@onready var health_bar = $GameScreen/HealthBar


func _ready():
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
	player.playerHealthUpdated.connect(UpdateHealthBar)

func UpdateHealthBar(newValue: int, maxValue: int):
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue
