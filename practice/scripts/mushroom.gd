extends CharacterBody2D
@export var speed = 750
@export var gravity = 40
@export var jump_force = 1000
@export var health = 3
@onready var sprite2d = $Sprite2D2
@onready var attackbox = $HitBox/CollisionBox
@onready var visionbox = $Vision/CollisionShape2D
var idle = 0
var stunned = false
var attacking = false
var attackanim = 1
var hit = null
var movementnum = 0
var direction = 1
var attackspeed = 0.4

func _physics_process(_delta):
	if sprite2d.animation == "death" or stunned == true:
		return
	movement()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	hit = body.name
	if hit.begins_with("Lava"):
		stunned = true
		death()
func _on_area_2d_area_entered(body: Node2D) -> void:
	if sprite2d.animation == "death":
		return
	hit = body.name
	print(hit)
	if hit.begins_with("PlayerHitBox") && stunned == false:
		health -= 1
		if health <= 0:
			stunned = true
			sprite2d.play("hurt")
			await get_tree().create_timer(0.2).timeout
			death()
		else:
			sprite2d.play("hurt")
			stunned = true
		await get_tree().create_timer(0.5).timeout
		if health > 0:
			sprite2d.play("idle")
		stunned = false
	elif hit.begins_with("TurnAround") && stunned == false:
		velocity.x = 0
		movementnum = 0
		direction *= -1
	
func _on_vision_area_entered(body: Area2D) -> void:
	if sprite2d.animation == "death":
		return
	hit = body.name
	print(hit)
	if hit == "OuchBox" && stunned == false:
		attacking = true
		while attacking == true:
			if sprite2d.animation == "death":
				return
			sprite2d.play("attack")
			velocity.x = 0
			movementnum = -1000
			await get_tree().create_timer(0.4).timeout
			if stunned == false:
				attackbox.disabled = false
			await get_tree().create_timer(0.4).timeout
			attackbox.set_deferred("disabled", true)
			await get_tree().create_timer(0.1).timeout
			if sprite2d.animation == "death":
				return
			sprite2d.play("idle")
			await get_tree().create_timer(attackspeed).timeout
			
		
func _on_vision_area_exited(body: Area2D) -> void:
	hit = body.name

	if hit == "OuchBox" && stunned == false:
		velocity.x = 0
		movementnum = 0
		await get_tree().create_timer(0.9).timeout
		attacking = false
		
func _ready():
	sprite2d.play("idle")
	
func movement():
	velocity.x = 0
	movementnum +=1
	if movementnum >= 50:
		velocity.x = -300*direction
		if direction < 0:
			sprite2d.flip_h = true
			attackbox.position.x = 48
			visionbox.position.x = 55
		else:
			sprite2d.flip_h = false
			attackbox.position.x = -30
			visionbox.position.x = -31.5
	move_and_slide()
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1500:
			velocity.y = 1500
	if attacking == true:
		return
	if velocity.x != 0 && is_on_floor():
		sprite2d.play("walk")
	else:
		sprite2d.play("idle")

func death():
	stunned = true
	sprite2d.play("death")
	$CollisionShape2D2.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	attackbox.set_deferred("disabled", true)
	await get_tree().create_timer(2).timeout
	for i in 10:
		sprite2d.modulate.a -= 0.1
		await get_tree().create_timer(0.05).timeout
	queue_free()
