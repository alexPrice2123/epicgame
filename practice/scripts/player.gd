extends CharacterBody2D
@export var speed = 750
@export var gravity = 40
@export var jump_force = 1000
@export var health = 3
@onready var sprite2d = $Sprite2D2
@onready var attackbox = $PlayerHitBox/PlayerCollisionBox
var idle = 0
var dead = false
var attacking = false
var attackanim = 1

func _physics_process(delta):
	if dead == true:
		return
	movement()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.begins_with("Lava"):
		dead = true
		sprite2d.play("player_death")
		await get_tree().create_timer(2).timeout
		get_tree().reload_current_scene()
	pass
	
func _ready():
	sprite2d.play("player_idle")

func _input(event: InputEvent) -> void:
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
		attackbox.disabled = false
		await get_tree().create_timer(0.5).timeout
		attackbox.disabled = true
		attacking = false
		
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
