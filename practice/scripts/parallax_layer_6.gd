extends ParallaxLayer
func _ready() -> void:
	for i in 32:
		var num = i+1
		get_node("Sprite%d" % num).play("Water")
