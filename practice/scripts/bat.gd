extends CharacterBody2D

var speed = 750
var steer_force = 250
var acceleration = Vector2.ZERO
var target = null

func _ready() -> void:
	target = get_tree().current_scene.get_node("Player")
	$Ball.play("Fly")

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
		return steer

func _physics_process(delta):
	if target == null:
		$Ball.play("Explosion")
		$Sound.stream = load("res://Sounds/Sounds/Explode.wav")
		$Sound.play()
		await get_tree().create_timer(1).timeout
		queue_free()
	if $Ball.animation != "Fly":
		return
	if target.position.x < position.x:
		$Ball.flip_h = false
	else:
		$Ball.flip_h = true
	acceleration += seek()
	velocity += acceleration * delta
	if abs(velocity.x) > speed:
		velocity.x = speed * abs(velocity.x)/velocity.x
	if abs(velocity.y) > speed:
		velocity.y = speed * abs(velocity.y)/velocity.y
	rotation = velocity.angle()
	$Ball.rotation = -rotation
	position += velocity * delta

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "OuchBox" && target == get_tree().current_scene.get_node("Player") && $Ball.animation == "Fly":
		$Ball.play("Explosion")
		$Sound.stream = load("res://Sounds/Sounds/Explode.wav")
		$Sound.play()
		await get_tree().create_timer(1).timeout
		queue_free()
	elif area.name == "PlayerHitBox":
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
		target = get_tree().current_scene.get_node("WoodenBlob")
		$Sound.stream = load("res://Sounds/Sounds/Pop.wav")
		$Sound.play()
		while position.distance_to(target.position) > 100:
			await get_tree().create_timer(0.01).timeout
		while target.attacking == true:
			await get_tree().create_timer(0.01).timeout
		$Ball.play("Explosion")
		$Sound.stream = load("res://Sounds/Sounds/Explode.wav")
		$Sound.play()
		await get_tree().create_timer(0.5).timeout
		target.damaged()
		await get_tree().create_timer(0.5).timeout
		queue_free()
