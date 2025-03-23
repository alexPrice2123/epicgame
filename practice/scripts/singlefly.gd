extends CharacterBody2D
@export var speed = 600
@export var gravity = 40
@export var jump_force = 1000
@export var health = 1
@export var spawn_coin = preload("res://Scenes/coin.tscn")
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
var velo = -750
		
func _ready():
	if randi_range(1,2) == 2:
		$Sprite2D2.flip_v = true
	sprite2d.play("charge")
	
	
func _physics_process(_delta):
	velocity.y = velo
	move_and_slide()
	
func _on_area_2d_area_entered(body: Node2D) -> void:
	if sprite2d.animation == "death":
		return
	hit = body.name
	if hit.begins_with("OuchBox") && stunned == false:
		sprite2d.play("attack")
		velo = -250
		await get_tree().create_timer(0.4).timeout
		sprite2d.play("charge")
		velo = -1000
