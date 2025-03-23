extends CharacterBody2D
var speed = 250
var steer_force = 50
var acceleration = Vector2.ZERO
var target = null
var hit = null

func _ready() -> void:
	target = get_tree().current_scene.get_node("Player")
	$Sprite.play("default")

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
		return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	if abs(velocity.x) > speed:
		velocity.x = speed * abs(velocity.x)/velocity.x
	if abs(velocity.y) > speed:
		velocity.y = speed * abs(velocity.y)/velocity.y
	rotation = velocity.angle()
	$Sprite.rotation = -rotation
	position += velocity * delta

func _on_gem_area_entered(area: Area2D) -> void:
	hit = area.name 
	if hit.begins_with("OuchBox"):
		queue_free()
