extends KinematicBody2D

onready var raycast : Physics2DDirectSpaceState = .get_world_2d().direct_space_state

func _ready():
	$AnimationPlayer.play("wiggle")
	


func _physics_process(delta):
	move_and_slide_with_snap(Vector2(-2000,0)*delta, Vector2.DOWN*50, Vector2.UP, false,4, 80)
	
	var _r := raycast.intersect_ray(global_position, global_position + Vector2.DOWN*100, [self])
	if _r:
		self.rotation = lerp(self.rotation, _r.normal.angle()+deg2rad(90), 0.1)
	
