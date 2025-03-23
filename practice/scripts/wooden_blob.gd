extends CharacterBody2D
@export var speed = 750
@export var gravity = 40
@export var jump_force = 1000
@export var health = 1
@export var spawn_coin = preload("res://Scenes/coin.tscn")
@export var bat = preload("res://Scenes/bat.tscn")
@onready var sprite2d = $Sprite2D2
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
	hit = body.name
	if sprite2d.animation == "death":
		return
	if hit.begins_with("Drop") && stunned == false:
		var roll = randi_range(1,6)
		if hit.begins_with("DropMust"):
			roll = 1
		if roll <= 2:
			attacking = true
			velocity.x = 0
			movementnum = -1000
			$Sprite2D2.play("smash_start")
			await get_tree().create_timer(1.5).timeout
			$Sound.stream = load("res://Sounds/Sounds/Fall.wav")
			$Sound.play()
			$Sprite2D2.play("smash")
			velocity.y = 750
			move_and_slide()
			while !is_on_floor():
				await get_tree().create_timer(0.01).timeout
			$Sprite2D2.play("smash_end")
			$Sound.stream = load("res://Sounds/Sounds/Plop.wav")
			$Sound.play()
			$BossHitBox/CollisionShape2D.set_deferred("disabled", false)
			await get_tree().create_timer(0.4).timeout
			$BossHitBox/CollisionShape2D.set_deferred("disabled", true)
			await get_tree().create_timer(0.4).timeout
			velocity.y = -500
			$Sprite2D2.play("idle")
			while position.y > -213.244262695312:
				await get_tree().create_timer(0.01).timeout
			velocity.y = 0
			movementnum = 25
			if roll == 1:
				direction *= -1
			attacking = false
	elif hit.begins_with("TurnAround") && stunned == false:
		await get_tree().create_timer(5.2).timeout
		if sprite2d.animation == "fly":
			velocity.x = 0
			movementnum = 0
			direction *= -1
		else:
			while sprite2d.animation != "idle":
				await get_tree().create_timer(0.5).timeout
	
func _ready():
	sprite2d.play_backwards("death")
	$Sound.stream = load("res://Sounds/Sounds/SummonBlob.mp3")
	$Sound.play()
	await get_tree().create_timer(1.7).timeout
	sprite2d.play("idle")
	
func movement():
	velocity.x = 0
	movementnum +=1
	if movementnum >= 250:
		attack()
	if movementnum >= 50:
		velocity.x = -300*direction
		if direction < 0:
			sprite2d.flip_h = true
		else:
			sprite2d.flip_h = false
	move_and_slide()
	if attacking == true:
		return
	if velocity.x != 0:
		sprite2d.play("fly")
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
	
func attack():
	attacking = true
	movementnum = -1000
	$Sprite2D2.play("attack")
	await get_tree().create_timer(1.2).timeout
	if stunned == false && attacking == true:
		var world = get_tree().get_root().get_node("World")
		var obj = bat.instantiate()
		if direction == 1:
			obj.position = Vector2(position.x-75, position.y)
		else:
			obj.position = Vector2(position.x+150, position.y)
		$Sound.stream = load("res://Sounds/Sounds/Bat.wav")
		$Sound.play()
		world.add_child(obj)
	await get_tree().create_timer(0.1).timeout
	attacking = false
	movementnum = 0

func damaged():
	health -= 1
	if health <= 0:
		$Sound.volume_db = 25
		$Sound.stream = load("res://Sounds/Sounds/DieBlob.wav")
		$Sound.play()
		stunned = true
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
