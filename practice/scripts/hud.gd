extends CanvasLayer
@export var health = 5
var gems = 0
var coins = 0
var lives = 3
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
