extends CanvasLayer
@export var health = 5
var gems = 0
var coins = 0

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
