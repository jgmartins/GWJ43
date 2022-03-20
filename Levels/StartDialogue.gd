extends Area2D


export (String) var DIALOGUE_RESOURCE

export (NodePath) var DIALOGUE_NODE
onready var diag_node : Dialogue = get_node(DIALOGUE_NODE)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		diag_node.run_diag_from_file(DIALOGUE_RESOURCE)
		body.restart_after_dialogue(diag_node)
	
	
