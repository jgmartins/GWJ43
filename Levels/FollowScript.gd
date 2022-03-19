tool
extends Node2D


export var EDITOR_MOVE_TO_POSITION := false
export var EDITOR_SET_DESIRED_OFFSET := false

export var LERP_SPEED := 1.0

export var desired_offset := Vector2()
export (NodePath) var TARGET_NODE setget _set_target
onready var target : Node2D = get_node(TARGET_NODE)

func _set_target(tn : NodePath):
	TARGET_NODE = tn
	if is_inside_tree() and has_node(tn):
		target = get_node(tn)

func _process(delta):
	
	# Desired offset depends on direction of character
	var directed_offset := desired_offset
	if not target.get_node("Sprite").flip_h:
		directed_offset = directed_offset * Vector2(-1,1)
	
	if target and (EDITOR_MOVE_TO_POSITION or not Engine.editor_hint):
		global_position = lerp(global_position, target.global_position + directed_offset, LERP_SPEED*delta)
	
	# If we have a target, are not automatically moving to positio but are in the editor,
	# then we can automatically update the desired_offset to target!
	if target and not EDITOR_MOVE_TO_POSITION and Engine.editor_hint and EDITOR_SET_DESIRED_OFFSET:
		desired_offset = global_position - target.global_position
