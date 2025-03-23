extends CharacterBody2D

var speed = 700

func _ready() -> void:
	$Ball.play("Fly")
	if speed < 0:
		$Ball.flip_h = true
	
func _physics_process(delta: float) -> void:
	velocity = Vector2(-speed,0)
	move_and_slide()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "OuchBox":
		get_parent().heal()
		queue_free()
	elif area.name == "PlayerHitBox":
		get_parent().get_node("Sound").stream = load("res://Sounds/Sounds/Pop.wav")
		get_parent().get_node("Sound").play()
		queue_free()
