extends CanvasLayer
@export var health = 5
var gems = 0
var coins = 0
var lives = 3
var open = false
var plr = null

func _ready() -> void:
	$Talk/TalkBox.frame = 44
	$Talk/TalkBox/OrgBox.modulate.a = 0
	plr = get_tree().get_root().get_node("World").get_node("Player")
	
func damaged():
	$Health/BarSprite.frame += 1
func healed(): 
	$Health/BarSprite.frame -= 1

func gem():
	gems +=1
	$GemBox/GemAmount.text = str(gems)

func coin():
	coins +=1
	$CoinBox/CoinAmount.text = str(coins)
func lost_life():
	lives = get_tree().get_root().get_node("World").get_node("Player").lives
	if lives == 3:
		pass
	elif lives == 2:
		$Health/Skull3.frame = 1
	elif lives == 1:
		$Health/Skull2.frame = 1
		$Health/Skull3.frame = 1
	elif lives <= 0:
		$Health/Skull.frame = 1
		$Health/Skull2.frame = 1
		$Health/Skull3.frame = 1

func openUI():
	if open == false:
		open = true
		$Talk/TalkBox.play_backwards("open")
		await get_tree().create_timer(1).timeout
		$Talk/TalkBox.frame = 0
		for i in 10:
			$Talk/TalkBox/OrgBox.modulate.a += 0.1
			await get_tree().create_timer(0.01).timeout
	
func closeUI():
	if open == true:
		open = false
		for i in 10:
			$Talk/TalkBox/OrgBox.modulate.a -= 0.1
			await get_tree().create_timer(0.01).timeout
		$Talk/TalkBox.play("open")


func _on_yes_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$Talk/TalkBox/OrgBox/Yes.icon = pressedbutton

func _on_yes_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$Talk/TalkBox/OrgBox/Yes.icon = pressedbutton
	if plr.classe == "brute":
		plr.classe = "warrior"
	else:
		plr.classe = "brute"
	closeUI()

func _on_no_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$Talk/TalkBox/OrgBox/No.icon = pressedbutton
	
func _on_no_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$Talk/TalkBox/OrgBox/No.icon = pressedbutton
	closeUI()
