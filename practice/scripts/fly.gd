extends CharacterBody2D
@export var speed = 600
@export var gravity = 40
@export var jump_force = 1000
@export var health = 1
@export var spawn_coin = preload("res://Scenes/coin.tscn")
@onready var sprite2d = $Sprite2D2
@onready var attackbox = $HitBox/CollisionBox
@export var radius = 200
@onready var visionbox = $Vision/CollisionShape2D
var idle = 0
var stunned = false
var attacking = false
var attackanim = 1
var hit = null
var movementnum = 0
var direction = 1
var attackspeed = 0.4
var startingpos = null

func _physics_process(_delta):
	$Range.global_position = startingpos
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
	elif hit.begins_with("OuchBox") && stunned == false:
		stunned = true
		sprite2d.play("attack")
		direction = (direction/abs(direction))*-1
		attackbox.set_deferred("disabled", false)
		await get_tree().create_timer(0.2).timeout
		attackbox.set_deferred("disabled", true)
		await get_tree().create_timer(0.4).timeout
		sprite2d.play("idle")
		stunned = false
		attacking = false
	elif hit.begins_with("Object") && attacking == true:
		stunned = true
		sprite2d.play("charge_end")
		$Sound.stream = load("res://Sounds/Sounds/Damage.wav")
		$Sound.play()
		$CollisionShape2D2.set_deferred("disabled", true)
		$Area2D/CollisionShape2D.set_deferred("disabled", true)
		attackbox.set_deferred("disabled", true)
		await get_tree().create_timer(2.5).timeout
		$Sound.stream = load("res://Sounds/Sounds/Dies.wav")
		$Sound.play()
		await get_tree().create_timer(2.5).timeout
		queue_free()
func _on_vision_area_entered(body: Area2D) -> void:
	if sprite2d.animation == "death":
		return
	hit = body.name
	if hit == "OuchBox" && stunned == false:
		print(body.get_parent().position.y - position.y)
		if (body.get_parent().position.y - position.y) < 0 && (body.get_parent().position.y - position.y) > -100 :
			attacking = true
			stunned = true
			sprite2d.play("charge_start")
			await get_tree().create_timer(0.6).timeout
			stunned = false
			sprite2d.play("charge")
			direction = 3*direction
		
func _ready():
	sprite2d.play("idle")
	startingpos = position
	
func movement():
	velocity.x = 0
	movementnum +=1
	if abs(startingpos.x-position.x) >= $Range/CollisionShape2D.shape.radius && attacking == false && stunned == false:
		velocity.x = 0
		movementnum = 50
		if attacking == true:
			direction = (direction/abs(direction))*-1
			sprite2d.play("idle")
			attacking = false
		else:
			direction *= -1
	if movementnum >= 1:
		velocity.x = -300*direction
		if direction < 0:
			sprite2d.flip_h = true
			attackbox.position.x = 39
			visionbox.position.x = 187.0
		else:
			sprite2d.flip_h = false
			attackbox.position.x = -30
			visionbox.position.x = -167.5
	move_and_slide()
	if attacking == true:
		return
	if velocity.x != 0 && is_on_floor():
		sprite2d.play("idle")
	else:
		sprite2d.play("idle")
		
func coindrops():
	var world = get_tree().get_root().get_node("World")
	var obj = spawn_coin.instantiate()
	obj.position = Vector2(position.x, position.y-125)
	world.add_child(obj)
	obj.z_index = z_index - 1
	
func death():
	stunned = true
	sprite2d.play("death")
	$CollisionShape2D2.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	attackbox.set_deferred("disabled", true)
	if attacking == true:
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
