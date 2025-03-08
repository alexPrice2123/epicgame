extends CanvasLayer
@export var health = 5

func damaged():
	$AnimatedSprite2D.frame += 1
func healed(): 
	$AnimatedSprite2D.frame -= 1
