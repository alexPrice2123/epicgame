extends Node2D
@export var cursor = preload("res://Images/hand.png")
var swamp = preload("res://Scenes/Swamp.tscn").instantiate()

func _ready() -> void:
	$Sprites/Skeli.play("default")
	if OS.has_feature("web"):
		$HUD/Control/Quit.visible = false
		$HUD/Control/Play/ButtonText.text = "Play Demo"
		$HUD/Control/Play/ButtonText.add_theme_font_size_override("font_size", 30)
	else:
		$HUD/Control/Mute.visible = false
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_POINTING_HAND, Vector2(0, 0))
	var times = 0.01
	for i in 100:
		$HUD/Control/Overlay.material.set_shader_parameter("progress", times)
		times += 0.01
		$Title.volume_db += 0.3
		position.x -= 2
		await get_tree().create_timer(0.01).timeout
	$HUD/Control/Overlay.visible = false
	$HUD/Control/Overlay.material.set_shader_parameter("fill", true)
	$HUD/Control/Play.disabled = false
	$HUD/Control/Quit.disabled = false
	$HUD/Control/Mute.disabled = false
	while true:
		position.x -= 2
		await get_tree().create_timer(0.01).timeout


func _on_play_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$HUD/Control/Play.icon = pressedbutton

func _on_play_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$HUD/Control/Play.icon = pressedbutton
	$Sound.stream = load("res://Sounds/Sounds/Confirm.wav")
	$Sound.play()
	$HUD/Control/Overlay.visible = true
	$HUD/Control/Play.disabled = true
	$HUD/Control/Quit.disabled = true
	var times = 0.01
	for i in 100:
		$HUD/Control/Overlay.material.set_shader_parameter("progress", times)
		times += 0.01
		$Title.volume_db -= 0.3
		await get_tree().create_timer(0.01).timeout
	print($Title.volume_db)
	get_tree().change_scene_to_file("res://Scenes/Swamp.tscn")
func _on_quit_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$HUD/Control/Quit.icon = pressedbutton


func _on_quit_button_up() -> void:
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$HUD/Control/Quit.icon = pressedbutton
	$Sound.stream = load("res://Sounds/Sounds/Cancel.wav")
	$Sound.play()
	$HUD/Control/Overlay.visible = true
	$HUD/Control/Play.disabled = true
	$HUD/Control/Quit.disabled = true
	var times = 0.01
	for i in 100:
		$HUD/Control/Overlay.material.set_shader_parameter("progress", times)
		times += 0.01
		$Title.volume_db -= 0.3
		await get_tree().create_timer(0.01).timeout
	get_tree().quit()


func _on_mute_button_down() -> void:
	var pressedbutton = load("res://Images/HUD/Button/Pressed.png")
	$HUD/Control/Mute.icon = pressedbutton


func _on_mute_button_up() -> void:
	$HUD/Control/Mute.disabled = true
	var pressedbutton = load("res://Images/HUD/Button/NormalButton.png")
	$HUD/Control/Mute.icon = pressedbutton
	if $Title.volume_db < -75:
		$Sound.stream = load("res://Sounds/Sounds/Confirm.wav")
		$Sound.play()
		$HUD/Control/Mute/ButtonText.text = "Mute"
		for i in 50:
			$Title.volume_db += 1
			await get_tree().create_timer(0.01).timeout
		$HUD/Control/Mute.disabled = false
	else:
		$Sound.stream = load("res://Sounds/Sounds/Cancel.wav")
		$HUD/Control/Mute/ButtonText.text = "Unmute"
		$Sound.play()
		for i in 50:
			$Title.volume_db -= 1
			await get_tree().create_timer(0.01).timeout
		print($Title.volume_db)
		$HUD/Control/Mute.disabled = false
