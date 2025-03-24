extends AnimatedSprite2D
var hit = null
var val = 0.01
var rand = randi_range(1,10)

func _ready() -> void:
	print(rand)
	if rand < 7:
		queue_free()
	play("spin")


func _on_area_2d_area_entered(body: Area2D) -> void:
	hit = body.name
	if hit.begins_with("OuchBox"):
		queue_free()
