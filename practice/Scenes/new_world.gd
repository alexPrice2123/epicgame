extends Node2D

var save_path = "user://skeleton.save"

func _ready() -> void:
	load_data()

func save():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var($Player.lives)
func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		$Player.lives = file.get_var($Player.lives)
		$Player/HUD.lost_life()
		print("Loaded")
	else:
		$Player.lives = 3
		print("No Save")

func _NOTIFICATION_WM_CLOSE_REQUEST():
	print("Closing")
	$Player.lives = 3
	get_tree().quit()
