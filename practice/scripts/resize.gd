@tool

extends CollisionShape2D

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		get_parent().global_position = get_parent().get_parent().position
	shape.radius = get_parent().get_parent().radius
