extends CharacterBody2D
@export var speed = 650
@export var gravity = 40
@export var jump_force = 950
@export var health = 5
@export var classe = "brute"
@onready var camera = $Camera2D
@onready var hud = $HUD
@onready var sprite2d = $Sprite2D2
@export var blob = preload("res://Scenes/wooden_blob.tscn")
@export var cursor = preload("res://Images/hand.png")
@onready var attackbox = $PlayerHitBox/PlayerCollisionBox
var buffer = 0
var idle = 0
var stunned = false
var attacking = false
var attackanim = 1
var zoomfactor = 0.05
var hit = null
var blobSpawned = false
var gems = 0
var coins = 0
var lives = 3
var pos = null
var jumpex = 0.02
var shouldland = false
var jumping = false
var canattack = true

func _physics_process(_delta):
	if sprite2d.animation == ("%s_death" % classe):
		return
	movement()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Lava"):
		stunned = true
		$Sound.stream = load("res://Sounds/Sounds/Dies.wav")
		$Sound.play()
		death()

func _ready():
	sprite2d.play("%s_idle" % classe)
	$HUD.damaged()
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_POINTING_HAND, Vector2(0, 0))

func _on_ouch_box_area_entered(body: Area2D) -> void:
	hit = body.name
	if hit == "HitBox":
		damaged()
	elif hit == "BossHitBox":
		bossdamaged()
	elif hit == "SignFirst":
		hud.tutOpen()
	elif hit == "DemoEnd":
		hud.END()
		$CollisionShape2D2.set_deferred("disabled", true)
		$OuchBox/CollisionShape2D.set_deferred("disabled", true)
		attackbox.set_deferred("disabled", true)
		sprite2d.play("%s_death" % classe)
	elif body.name.begins_with("Gem"):
		gems += 1
		hud.gem()
		$Sound.stream = load("res://Sounds/Sounds/Get_Gem.wav")
		$Sound.play()
	elif body.name.begins_with("Potion"):
		health += 1
		hud.damaged()
		$Sound.stream = load("res://Sounds/Sounds/Potion.wav")
		$Sound.play()
		if health >= 3 && classe == "warrior":
			health = 3
		elif health >= 5 && classe == "brute":
			health = 5
	elif body.name.begins_with("Coin"):
		coins += 1
		hud.coin()
		$Sound.stream = load("res://Sounds/Sounds/Get_Coin.wav")
		$Sound.play()
	elif body.name.begins_with("Bones"):
		$HUD.openUI()

func _on_ouch_box_area_exited(body: Area2D) -> void:
	hit = body.name
	if hit == "HitBox":
		await get_tree().create_timer(0.5).timeout
		if sprite2d.animation == ("%s_death" % classe) or health <= 0:
			return
		stunned = false
	elif body.name.begins_with("Bones"):
		$HUD.closeUI()
	elif hit == "SignFirst":
		hud.tutClose()

func _input(_event: InputEvent) -> void:
	if sprite2d.animation == ("%s_death" % classe):
		return
	if Input.is_action_just_pressed("jump"):
		jumping = true
	elif Input.is_action_just_released("jump"):
		jumping = false
	if classe == "brute":
		if stunned == true:
			return
	if Input.is_action_just_pressed("move_left"):
		sprite2d.flip_h = true
		sprite2d.offset.x = 0
		attackbox.position.x = -45
	elif Input.is_action_just_pressed("move_right"):
		sprite2d.flip_h = false
		sprite2d.offset.x = 5
		attackbox.position.x = 57.5
	if Input.is_action_just_pressed("attack") && canattack == true:
		attacking = true
		canattack = false
		if attackanim == 1:
			sprite2d.play("%s_attack" % classe)
			attackanim = 2
		else:
			sprite2d.play("%s_attack2" % classe)
			attackanim = 1
		if classe == "brute":
			await get_tree().create_timer(0.3).timeout
		else:
			await get_tree().create_timer(0.2).timeout
		if stunned == false:
			$Sound.stream = load("res://Sounds/Sounds/Slash.wav")
			$Sound.play()
			$Sound.pitch_scale = randf_range(0.81,1.2)
			attackbox.disabled = false
		if classe == "brute":
			await get_tree().create_timer(0.5).timeout
		else:
			await get_tree().create_timer(0.3).timeout
		$Sound.pitch_scale = 1
		attackbox.set_deferred("disabled", true)
		attacking = false
		await get_tree().create_timer(0.2).timeout
		canattack = true
	if Input.is_action_just_pressed("scroll_in") && blobSpawned == false:
		camera.zoom.x += zoomfactor
		camera.zoom.y += zoomfactor
		if camera.zoom.y >= 2:
			camera.zoom.y = 2
			camera.zoom.x = 2
	if Input.is_action_just_pressed("scroll_out") && blobSpawned == false:
		camera.zoom.x -= zoomfactor
		camera.zoom.y -= zoomfactor
		if camera.zoom.y <= 0.5:
			camera.zoom.y = 0.5
			camera.zoom.x = 0.5
	if Input.is_action_just_pressed("quit"):
		#quit()
		pass

func quit():
	lives = 3
	get_tree().get_root().get_node("World").save()

func movement():
	var h_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * h_direction
	move_and_slide()
	if !is_on_floor():
		buffer += 1
		shouldland = true
		if health > 0:
			velocity.y += gravity
			if velocity.y > 1500:
				velocity.y = 1500
		if buffer < 5 && buffer > -5 && jumping == true :
			velocity.y = -jump_force
			buffer = -150
			for i in 10:
				$Sprite2D2.scale.y += jumpex*2
				$Sprite2D2.scale.x -= jumpex
				await get_tree().create_timer(0.01).timeout
			for i in 10:
				$Sprite2D2.scale.y -= jumpex*2
				$Sprite2D2.scale.x += jumpex*2
				await get_tree().create_timer(0.01).timeout
			for i in 10:
				$Sprite2D2.scale.x -= jumpex
				await get_tree().create_timer(0.01).timeout
	else:
		buffer = 0
		if is_on_floor() && jumping == true :
			velocity.y = -jump_force
			for i in 10:
				$Sprite2D2.scale.y += jumpex*2
				$Sprite2D2.scale.x -= jumpex
				await get_tree().create_timer(0.01).timeout
			for i in 10:
				$Sprite2D2.scale.y -= jumpex*2
				$Sprite2D2.scale.x += jumpex*2
				await get_tree().create_timer(0.01).timeout
			for i in 10:
				$Sprite2D2.scale.x -= jumpex
				await get_tree().create_timer(0.01).timeout
		if position.y < 900 && velocity.y != 210:
			pos = position
	if attacking == true:
		return
	if sprite2d.animation == ("%s_death" % classe) or stunned == true:
		return
	if velocity.x != 0 && is_on_floor():
		sprite2d.play("%s_walk" % classe)
	else:
		sprite2d.play("%s_idle" % classe)

func damaged():
	stunned = true
	health -= 1
	hud.damaged()
	if health > 0:
		sprite2d.frame = 0
		sprite2d.play("%s_hurt" % classe)
		$Sound.stream = load("res://Sounds/Sounds/Damage.wav")
		$Sound.play()
	else:
		sprite2d.play("%s_hurt" % classe)
		$CollisionShape2D2.set_deferred("disabled", true)
		$OuchBox/CollisionShape2D.set_deferred("disabled", true)
		attackbox.set_deferred("disabled", true)
		$Sound.stream = load("res://Sounds/Sounds/Dies.wav")
		$Sound.play()
		await get_tree().create_timer(0.2).timeout
		death()

func bossdamaged():
	stunned = true
	health -= 1
	hud.damaged()
	if health > 0:
		sprite2d.frame = 0
		sprite2d.play("%s_hurt" % classe)
		$Sound.stream = load("res://Sounds/Sounds/Damage.wav")
		$Sound.play()
		await get_tree().create_timer(0.5).timeout
		stunned = false
	else:
		sprite2d.play("%s_hurt" % classe)
		$CollisionShape2D2.set_deferred("disabled", true)
		$OuchBox/CollisionShape2D.set_deferred("disabled", true)
		attackbox.set_deferred("disabled", true)
		$Sound.stream = load("res://Sounds/Sounds/Dies.wav")
		$Sound.play()
		await get_tree().create_timer(0.2).timeout
		death()

func death():
	stunned = true
	jumping = false
	$CollisionShape2D2.set_deferred("disabled", true)
	$OuchBox/CollisionShape2D.set_deferred("disabled", true)
	attackbox.set_deferred("disabled", true)
	sprite2d.play("%s_death" % classe)
	lives -= 1
	hud.lost_life()
	if lives <= 0:
		lives = 3
		get_tree().get_root().get_node("World").save()
		await get_tree().create_timer(2).timeout
		$Sound.stream = load("res://Sounds/Sounds/GameOver.wav")
		$Sound.play()
		$HUD.died()
	else:
		get_tree().get_root().get_node("World").save()
		await get_tree().create_timer(2).timeout
		$Sound.stream = load("res://Sounds/Sounds/Heal.wav")
		$Sound.play()
		sprite2d.play_backwards("%s_death" % classe)
		position = pos
		for i in 12:
			await get_tree().create_timer(0.1).timeout
			if i == 0 or i == 2 or i == 4 or i == 6 or i == 8 or i == 10 or i == 12:
				$Sprite2D2.modulate = Color(255,255,255,255)
			else:
				$Sprite2D2.modulate = Color(1,1,1,1)
		$CollisionShape2D2.set_deferred("disabled", false)
		$OuchBox/CollisionShape2D.set_deferred("disabled", true)
		stunned = false 
		if classe == "brute":
			health = 5
		else:
			health = 3
		$HUD.damaged()
		sprite2d.play("%s_idle" % classe)
		for i in 12:
			await get_tree().create_timer(0.1).timeout
			if i == 0 or i == 2 or i == 4 or i == 6 or i == 8 or i == 10 or i == 12:
				$Sprite2D2.modulate = Color(255,255,255,255)
			else:
				$Sprite2D2.modulate = Color(1,1,1,1)
		$Sprite2D2.modulate = Color(1,1,1,1)
		$OuchBox/CollisionShape2D.set_deferred("disabled", false)

func summonBlob():
	blobSpawned = true
	while camera.zoom.y > 0.75:
		camera.zoom.x -= 0.03
		camera.zoom.y -= 0.03
		await get_tree().create_timer(0.01).timeout
	var world = get_tree().get_root().get_node("World")
	var obj = blob.instantiate()
	obj.position = Vector2(position.x, position.y-850)
	world.get_node("TileHolder").get_node("Pillars").position.y = 0
	for i in 25: 
		camera.zoom.x -= 0.02
		camera.zoom.y -= 0.02
		if camera.zoom.y < 0.4:
			camera.zoom.y = 0.4
			camera.zoom.x = 0.4
		camera.position.y -= 6.5
		await get_tree().create_timer(0.01).timeout
	get_tree().get_current_scene().get_node("MiniBoss").play()
	world.add_child(obj)
	for i in 10:
		get_tree().get_current_scene().get_node("Swamp").volume_db -= 0.4
		get_tree().get_current_scene().get_node("MiniBoss").volume_db += 0.4
		await get_tree().create_timer(0.01).timeout
	for i in 100:
		get_tree().get_current_scene().get_node("Swamp").volume_db -= 0.4
		get_tree().get_current_scene().get_node("MiniBoss").volume_db += 0.4
		await get_tree().create_timer(0.01).timeout
	get_tree().get_current_scene().get_node("Swamp").volume_db -= 300

func deadBlob():
	var world = get_tree().get_root().get_node("World")
	for i in 25: 
		world.get_node("TileHolder").get_node("Pillars").position.y += 2
		camera.zoom.x += 0.01
		camera.zoom.y += 0.01
		camera.position.y += 6.5
		await get_tree().create_timer(0.01).timeout
	blobSpawned = false
	get_tree().get_current_scene().get_node("Swamp").volume_db = -69
	for i in 10:
		world.get_node("TileHolder").get_node("Pillars").position.y += 2
		get_tree().get_current_scene().get_node("Swamp").volume_db += 0.4
		get_tree().get_current_scene().get_node("MiniBoss").volume_db -= 0.4
		await get_tree().create_timer(0.01).timeout
	for i in 100:
		world.get_node("TileHolder").get_node("Pillars").position.y += 2
		get_tree().get_current_scene().get_node("Swamp").volume_db += 0.4
		get_tree().get_current_scene().get_node("MiniBoss").volume_db -= 0.4
		await get_tree().create_timer(0.01).timeout
