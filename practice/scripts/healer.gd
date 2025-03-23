extends CharacterBody2D
@export var speed = 750
@export var gravity = 40
@export var jump_force = 1000
@export var health = 3
@export var spawn_coin = preload("res://Scenes/coin.tscn")
@export var sap = preload("res://Scenes/sap.tscn")
@onready var sprite2d = $Sprite2D2
@onready var visionbox = $Vision/CollisionShape2D
var idle = 0
var stunned = false
var attacking = false
var attackanim = 1
var hit = null
var movementnum = 0
var direction = 1
var attackspeed = 1

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
	if hit.begins_with("PlayerHitBox") && stunned == false:
		health -= 1
		if health <= 0:
			$Sound.stream = load("res://Sounds/Sounds/Dies.wav")
			$Sound.play()
			stunned = true
			sprite2d.play("hurt")
			await get_tree().create_timer(0.2).timeout
			death()
		else:
			$Sound.stream = load("res://Sounds/Sounds/Damage.wav")
			$Sound.play()
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
	if hit == "OuchBox" && stunned == false:
		attacking = true
		visionbox.scale.y = 25
		if sprite2d.animation == "death":
			return
		sprite2d.play("attack")
		velocity.x = 0
		movementnum = -100
		await get_tree().create_timer(1).timeout
		if stunned == false && attacking == true:
			var world = get_tree().get_root().get_node("World")
			var obj = sap.instantiate()
			if direction == 1:
				obj.position = Vector2(-30, -50)
			else:
				obj.position = Vector2(80, -50)
			obj.speed *= direction
			add_child(obj)
		await get_tree().create_timer(0.4).timeout
		if sprite2d.animation == "death":
			return
		sprite2d.play("idle")
		$Vision/CollisionShape2D.set_deferred("disabled", true)
		await get_tree().create_timer(attackspeed).timeout
		$Vision/CollisionShape2D.set_deferred("disabled", false)
		
func _on_vision_area_exited(body: Area2D) -> void:
	hit = body.name
	visionbox.scale.y = 1

	if hit == "OuchBox" && stunned == false:
		velocity.x = 0
		movementnum = 0
		checkaround()
		attacking = false
		
func _ready():
	sprite2d.play("idle")
	
func movement():
	velocity.x = 0
	movementnum +=1
	if movementnum >= 350:
		checkaround()
	if movementnum >= 50:
		velocity.x = -300*direction
		if direction < 0:
			sprite2d.flip_h = true
			visionbox.position.x = 229.5
		else:
			sprite2d.flip_h = false
			visionbox.position.x = -210.0
	move_and_slide()
	if attacking == true:
		return
	if velocity.x != 0 && is_on_floor():
		sprite2d.play("walk")
	else:
		sprite2d.play("idle")
func coindrops():
	var world = get_tree().get_root().get_node("World")
	var obj = spawn_coin.instantiate()
	obj.position = Vector2(position.x, position.y-110)
	world.add_child(obj)
	obj.z_index = z_index - 1
	
func death():
	stunned = true
	sprite2d.play("death")
	$CollisionShape2D2.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	coindrops()
	await get_tree().create_timer(2).timeout
	for i in 10:
		sprite2d.modulate.a -= 0.1
		await get_tree().create_timer(0.05).timeout
	queue_free()

func checkaround():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.1).timeout
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	
func heal():
	health += 1
	if health >= 6:
		health = 5
	else:
		$Sound.stream = load("res://Sounds/Sounds/Potion.wav")
		$Sound.play()
		$Sprite2D2.play("boost")
		stunned = true
		attacking = false
		await get_tree().create_timer(0.7).timeout
		if sprite2d.animation == "death":
			return
		attacking = true
		stunned = false
