extends AnimatedSprite2D

func _ready() -> void:
	play("Rock")

func _on_summon_area_entered(area: Area2D) -> void:
	if area.name == "OuchBox":
		area.get_parent().summonBlob()
		$Summon/Box.set_deferred("disabled", true)
