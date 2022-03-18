extends Area2D


export (int) var direction = -90
export (float) var strength = 100

func get_force(character) -> Vector2:
	return Vector2.RIGHT.rotated(deg2rad(direction))*strength

func _on_Wind_body_entered(body) -> void:
	if body is Character:
		body.add_external_force(self)


func _on_Wind_body_exited(body) -> void:
	if body is Character:
		body.remove_external_force(self)
