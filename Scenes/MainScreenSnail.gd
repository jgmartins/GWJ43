extends KinematicBody2D

onready var raycast : Physics2DDirectSpaceState = .get_world_2d().direct_space_state

export var VEL : float = 2000

export var particle_offset = Vector2(22, 24)

func _ready():
	$AnimationPlayer.play("wiggle")
	


func _physics_process(delta):
	
	var dir := Vector2(0, 0)
	
	if Input.is_action_pressed("ui_left"):
		$AnimationPlayer.play("wiggle")
		$Particles2D.emitting = true
		dir = Vector2(-VEL,0)*delta
		_turned_right(false)
	elif Input.is_action_pressed("ui_right"):
		$Particles2D.emitting = true
		$AnimationPlayer.play("wiggle")
		dir = Vector2(VEL,0)*delta
		_turned_right(true)
	else:
		$Particles2D.emitting = false
		$AnimationPlayer.stop()
		$Sprite.scale.x = lerp($Sprite.scale.x, 2.133, delta)
		$Sprite.scale.y = lerp($Sprite.scale.y, 2.133, delta)
	
	var _ignore := move_and_slide_with_snap(dir, Vector2.DOWN*200, Vector2.UP, false,4, 80)
	
	var _r := raycast.intersect_ray(global_position, global_position + Vector2.DOWN*200, [self])
	if _r:
		self.rotation = lerp(self.rotation, _r.normal.angle()+deg2rad(90), 0.1)
	
func _turned_right(is_right : bool) -> void:
	$Sprite.flip_h = is_right
	var particle_pos = particle_offset
	if is_right:
		particle_pos = particle_pos * Vector2(-1, 1)
	$Particles2D.position = particle_pos
