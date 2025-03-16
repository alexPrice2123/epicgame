extends CharacterBody2D
var plr = null

func _ready() -> void:
	$AnimatedSprite2D.play("idle")


func _physics_process(_delta):
	plr = get_tree().get_root().get_node("World").get_node("Player")
	print(plr.position.x)
	if plr.position.x < position.x:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
