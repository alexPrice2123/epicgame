extends CharacterBody2D
@export var speed = 750
@export var gravity = 40
@export var jump_force = 1000
@export var health = 3
@onready var sprite2d = $Sprite2D2
@onready var attackbox = $HitBox/CollisionBox
var idle = 0
var dead = false
var attacking = false
var attackanim = 1
var hit = null
func _physics_process(delta):
	if dead == true:
		return
	movement()
	
func _on_area_2d_area_entered(body: Node2D) -> void:
	hit = body.name
	if hit.begins_with("Lava"):
		dead = true
		sprite2d.play("death")
	elif hit.begins_with("PlayerHitBox") && dead == false:
		health -= 1
		if health <= 0:
			dead = true
			sprite2d.play("hurt")
			await get_tree().create_timer(0.2).timeout
			sprite2d.play("death")
			$CollisionShape2D2.set_deferred("disabled", true)
			$Area2D/CollisionShape2D.set_deferred("disabled", true)
			attackbox.set_deferred("disabled", true)
			await get_tree().create_timer(2).timeout
			queue_free()
		else:
			sprite2d.play("hurt")
			dead = true
		await get_tree().create_timer(0.5).timeout
		if health > 0:
			sprite2d.play("idle")
			dead = false
	pass
	
func _ready():
	sprite2d.play("idle")
		
func movement():
	move_and_slide()
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1500:
			velocity.y = 1500
	if attacking == true:
		return
	if velocity.x != 0 && is_on_floor():
		sprite2d.play("player_walk")
	else:
		sprite2d.play("idle")
