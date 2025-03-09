extends AnimatedSprite2D
var hit = null

func _ready() -> void:
	play("spin")

func _on_area_2d_area_entered(body: Area2D) -> void:
	hit = body.name
	print(hit)
	if hit.begins_with("OuchBox"):
		queue_free()
