extends CharacterBody2D
@export var speed = 650
@export var gravity = 40
@export var jump_force = 950
@export var health = 5
@export var classe = "brute"
@onready var camera = $Camera2D
@onready var hud = $HUD
@onready var sprite2d = $Sprite2D2
@onready var attackbox = $PlayerHitBox/PlayerCollisionBox
var idle = 0
var stunned = false
var attacking = false
var attackanim = 1
var zoomfactor = 0.15
var hit = null
var gems = 0
var coins = 0
var lives = 3
var pos = null

func _physics_process(_delta):
	if sprite2d.animation == ("%s_death" % classe):
		return
	movement()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Lava"):
		stunned = true
		death()
	
func _ready():
	sprite2d.play("%s_idle" % classe)
	$HUD.damaged()
	await get_tree().create_timer(0.1).timeout

func _on_ouch_box_area_entered(body: Area2D) -> void:
	hit = body.name
	if hit == "HitBox":
		damaged()
	elif body.name.begins_with("Gem"):
		gems += 1
		hud.gem()
	elif body.name.begins_with("Coin"):
		coins += 1
		hud.coin()
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
func _input(_event: InputEvent) -> void:
	if sprite2d.animation == ("%s_death" % classe):
		return
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
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_force
	if Input.is_action_just_pressed("attack") && attacking == false:
		attacking = true
		if attackanim == 1:
			sprite2d.play("%s_attack" % classe)
			attackanim = 2
		else:
			sprite2d.play("%s_attack2" % classe)
			attackanim = 1
		await get_tree().create_timer(0.5).timeout
		if stunned == false:
			attackbox.disabled = false

		if classe == "brute":
			await get_tree().create_timer(0.5).timeout
		else:
			await get_tree().create_timer(0.3).timeout
		attackbox.set_deferred("disabled", true)
		attacking = false
	if Input.is_action_just_pressed("scroll_in"):
		camera.zoom.x += zoomfactor
		camera.zoom.y += zoomfactor
		if camera.zoom.y >= 3:
			camera.zoom.y = 3
			camera.zoom.x = 3
	if Input.is_action_just_pressed("scroll_out"):
		camera.zoom.x -= zoomfactor
		camera.zoom.y -= zoomfactor
		if camera.zoom.y <= 0.75:
			camera.zoom.y = 0.75
			camera.zoom.x = 0.75
	if Input.is_action_just_pressed("quit"):
		lives = 3
		get_tree().get_root().get_node("World").save()
		get_tree().quit()
		
func movement():
	var h_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * h_direction
	move_and_slide()
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1500:
			velocity.y = 1500
	else:
		if position.y < 900:
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
	else:
		sprite2d.play("%s_hurt" % classe)
		$CollisionShape2D2.set_deferred("disabled", true)
		$OuchBox/CollisionShape2D.set_deferred("disabled", true)
		attackbox.set_deferred("disabled", true)
		await get_tree().create_timer(0.2).timeout
		death()
func death():
	stunned = true
	$CollisionShape2D2.set_deferred("disabled", true)
	$OuchBox/CollisionShape2D.set_deferred("disabled", true)
	attackbox.set_deferred("disabled", true)
	sprite2d.play("%s_death" % classe)
	lives -= 1
	hud.lost_life()
	if lives <= -1:
		lives = 3
		get_tree().get_root().get_node("World").save()
		await get_tree().create_timer(2).timeout
		get_tree().reload_current_scene()
	else:
		get_tree().get_root().get_node("World").save()
		await get_tree().create_timer(2).timeout
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
		
