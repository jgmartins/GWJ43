tool
extends AnimatedSprite

export var H_LIMITS := Vector2(0, 1600)
export var V_LIMITS := Vector2(600, 750)
export var PARALLAX_AMNT := Vector2(100, 100)
export var OFFSET := Vector2(0, -50)

export (NodePath) var TARGET_NODE setget _set_target
onready var target : Node2D = get_node(TARGET_NODE)

func _set_target(tn : NodePath):
	TARGET_NODE = tn
	if is_inside_tree() and has_node(tn):
		target = get_node(tn)

func _ready():
	frame = 0

func _process(_delta):
	if not target:
		return
		
	var mid_points := Vector2((H_LIMITS.y - H_LIMITS.x) / 2 + H_LIMITS.x, (V_LIMITS.y - V_LIMITS.x) / 2 + V_LIMITS.x)
	
	var new_pos = -(target.global_position - mid_points) / mid_points
	new_pos = new_pos * PARALLAX_AMNT
	new_pos.x = clamp(new_pos.x, -PARALLAX_AMNT.x, PARALLAX_AMNT.x) + OFFSET.x
	new_pos.y = clamp(new_pos.y, -PARALLAX_AMNT.y, PARALLAX_AMNT.y) + OFFSET.y
	
	position = new_pos

func start_playing() :
	playing = true
