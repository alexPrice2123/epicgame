extends CanvasLayer
@export var health = 5
var gems = 0
var coins = 0
var lives = 3
var open = false
var plr = null

func _ready() -> void:
	$Talk/TalkBox.frame = 44
	$Talk/TalkBox/Header.frame = 27
	$Menu/MenuBox.frame = 19
	$Talk/TalkBox/OrgBox.modulate.a = 0
	$Menu/MenuBox/OrgBox.modulate.a = 0
	$Talk/TalkBox/OrgBox/Yes.visible = false
	$Talk/TalkBox/OrgBox/No.visible = false
	$Menu/MenuBox/OrgBox/YesDead.visible = false
	$Menu/MenuBox/OrgBox/NoDead.visible = false
	plr = get_tree().get_root().get_node("World").get_node("Player")
	$Menu/MenuBox/Overlay.material.set_shader_parameter("fill", false)
	var times = 0.01
	for i in 100:
		$Menu/MenuBox/Overlay.material.set_shader_parameter("progress", times)
		times += 0.01
		await get_tree().create_timer(0.01).timeout
	$Menu/MenuBox/Overlay.material.set_shader_parameter("fill", true)
	$Menu/MenuBox/Overlay.visible = false
func damaged():
	$Health/BarSprite.animation = ("%sHealth" % plr.classe)
	$Health/BarSprite.frame = plr.health

func gem():
	gems +=1
	$GemBox/Gem/Control/GemAmount.text = str(gems)

func coin():
	coins +=1
	$CoinBox/Coin/Control/CoinAmount.text = str(coins)
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
		$Talk/TalkBox/Header.play_backwards("open")
		await get_tree().create_timer(1).timeout
		$Talk/TalkBox/OrgBox/Yes.visible = true
		$Talk/TalkBox/OrgBox/No.visible = true
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
		$Talk/TalkBox/Header.play("open")
		$Talk/TalkBox/OrgBox/Yes.visible = false
		$Talk/TalkBox/OrgBox/No.visible = false
		print($Talk/TalkBox/OrgBox/No.visible)


func _on_yes_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$Talk/TalkBox/OrgBox/Yes.icon = pressedbutton

func _on_yes_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$Talk/TalkBox/OrgBox/Yes.icon = pressedbutton
	plr.get_node("Sound").stream = load("res://Sounds/Sounds/Confirm.wav")
	plr.get_node("Sound").play()
	if plr.classe == "brute":
		if plr.health >= 5:
			plr.health = 3
		plr.classe = "warrior"
		$Health/BarSprite.animation = ("%sHealth" % plr.classe)
		$Health/BarSprite.frame = plr.health
		closeUI()
		await get_tree().create_timer(0.5).timeout
		$Talk/TalkBox/OrgBox/Text.text = "Hey there fello travaler! Would you like to change your class to Brute?"
	else:
		if plr.health >= 3:
			plr.health = 5
		plr.classe = "brute"
		$Health/BarSprite.animation = ("%sHealth" % plr.classe)
		$Health/BarSprite.frame = plr.health
		closeUI()
		await get_tree().create_timer(0.5).timeout
		$Talk/TalkBox/OrgBox/Text.text = "Hey there fello travaler! Would you like to change your class to Warrior?"

func _on_no_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$Talk/TalkBox/OrgBox/No.icon = pressedbutton
	
func _on_no_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$Talk/TalkBox/OrgBox/No.icon = pressedbutton
	plr.get_node("Sound").stream = load("res://Sounds/Sounds/Cancel.wav")
	plr.get_node("Sound").play()
	closeUI()

func died():
	$Menu/MenuBox.play_backwards("open")
	await get_tree().create_timer(0.3).timeout
	$Menu/MenuBox/OrgBox/YesDead.visible = true
	$Menu/MenuBox/OrgBox/NoDead.visible = true
	for i in 10:
		$Menu/MenuBox/OrgBox.modulate.a += 0.1
		get_tree().get_current_scene().get_node("Swamp").volume_db -= 0.4
		await get_tree().create_timer(0.01).timeout
	for i in 100:
		get_tree().get_current_scene().get_node("Swamp").volume_db -= 0.4
		await get_tree().create_timer(0.01).timeout
	get_tree().get_current_scene().get_node("Swamp").volume_db -= 300
func _on_yes_dead_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$Menu/MenuBox/OrgBox/YesDead.icon = pressedbutton


func _on_yes_dead_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$Menu/MenuBox/OrgBox/YesDead.icon = pressedbutton
	plr.get_node("Sound").stream = load("res://Sounds/Sounds/Confirm.wav")
	plr.get_node("Sound").play()
	$Menu/MenuBox/Overlay.visible = true
	var times = 0.01
	for i in 100:
		$Menu/MenuBox/Overlay.material.set_shader_parameter("progress", times)
		times += 0.01
		await get_tree().create_timer(0.01).timeout
	get_tree().reload_current_scene()

func _on_no_dead_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$Menu/MenuBox/OrgBox/NoDead.icon = pressedbutton


func _on_no_dead_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$Menu/MenuBox/OrgBox/NoDead.icon = pressedbutton
	plr.get_node("Sound").stream = load("res://Sounds/Sounds/Cancel.wav")
	plr.get_node("Sound").play()
	$Menu/MenuBox/Overlay.visible = true
	var times = 0.01
	for i in 100:
		$Menu/MenuBox/Overlay.material.set_shader_parameter("progress", times)
		times += 0.01
		await get_tree().create_timer(0.01).timeout
	plr.quit()
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
