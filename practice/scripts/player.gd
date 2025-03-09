extends CharacterBody2D
@export var speed = 650
@export var gravity = 40
@export var jump_force = 950
@export var health = 5
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

func _physics_process(_delta):
	if sprite2d.animation == "death" or stunned == true:
		return
	movement()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Lava"):
		death()
	
func _ready():
	sprite2d.play("player_idle")

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

func _input(_event: InputEvent) -> void:
	if sprite2d.animation == "death" or stunned == true:
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
			sprite2d.play("player_attack")
			attackanim = 2
		else:
			sprite2d.play("player_attack2")
			attackanim = 1
		await get_tree().create_timer(0.5).timeout
		if stunned == false:
			attackbox.disabled = false
		await get_tree().create_timer(0.5).timeout
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
		
func movement():
	var h_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * h_direction
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
		sprite2d.play("player_idle")
		
func damaged():
	stunned = true
	health -= 1
	hud.damaged()
	if health > 0:
		sprite2d.play("player_hurt")
		await get_tree().create_timer(0.5).timeout
		stunned = false
	else:
		sprite2d.play("player_hurt")
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
	sprite2d.play("player_death")
	await get_tree().create_timer(2).timeout
	get_tree().reload_current_scene()
