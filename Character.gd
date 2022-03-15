extends KinematicBody2D




# Vertical velocity to set when jumping, e.g. 300 px/s
export (float) var JUMP = 300
# Force of gravity! e.g. velocity will change by 1000 px/s per second
export (float) var G = 1000
# Horizontal acceleration of character when moving
export (float) var H_ACCEL = 1000
# Horizontal braking acceleration when on ground
export (float) var H_BRAKE = 300
# Horizontal braking acceleration when airborne
export (float) var H_BRAKE_AIR = 300
# Maximum horizontal velocity
export (float) var MAX_H_VEL = 300
export (Vector2) var SNAP_VECTOR := Vector2.DOWN * 100

# CRICKET LEG TIME
# Is cricket mode activated?
export (bool) var CRICKET_MODE = true
# How much extra speed to add for a cricket jump
export (float) var CRICKET_JUMP = 300


# DRAGON FLY WING TIME
# Is dragonfly mode activted?
export (bool) var DRAGONFLY_MODE = true
# How much to offset the effects of gravity: 0 is no gravity, 1 is full gravity
export (float, 0, 200) var MAX_FALL_V = 10
# Horizontal braking acceleration when wings enabled
export (float, 0, 500) var DF_BRAKE_AIR = 50
export (bool) var df_wings_deployed = false

# GOAT DOUBLE JUMP TIME
export (bool) var GOAT_MODE = true
export (int, 0, 3) var GT_NUM_JUMPS = 1
export (int) var gt_jumps_left = 0

# SQUIRREL WALL GRAB TIME
export (bool) var SQUIRREL_MODE = true
export (bool) var sq_grabbed = false

# Linear velocity
var v : Vector2 = Vector2(0,0)

func _ready():
	$AnimationPlayer.play("Stand")

func _draw():
	if get_slide_count():
		var col := get_last_slide_collision()
		draw_line(to_local(col.position), to_local(col.position + col.normal*100), Color.red,2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#update()
	# If the snap vector intersects the ground,
	# the character will remain in contact with it when moving
	var snap_vector := SNAP_VECTOR

	# JUMPING
	if Input.is_action_just_pressed("ui_up"):
		# If we're trying to jump, make sure snap vector allows
		# character to move out of contact with ground
		snap_vector = Vector2()
		jump()
	
	# DEPLOYING WINGS
	if Input.is_action_just_pressed("ui_down") and not is_on_floor():
		df_wings_deployed = not df_wings_deployed
	
	# MOVING LEFT AND RIGHT
	if Input.is_action_pressed("ui_left"):
		v.x = clamp(v.x - H_ACCEL*delta, -MAX_H_VEL, 1.79769e308)
		move_dir_change(true)
	if Input.is_action_pressed("ui_right"):
		v.x = clamp(v.x + H_ACCEL*delta, -1.79769e308, MAX_H_VEL)
		move_dir_change(false)
	
	# BRAKING
	if not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		brake(delta)
	
	# BRING CHARACTER TO ABSOLUTE STOP
	if (abs(v.x) < 2) and v.x != 0:
		stop()
		v.x = 0

	# Actually move the character
	v.y = move_and_slide_with_snap(v, snap_vector, Vector2.UP,true,4,deg2rad(70)).y
	
	
	# If we're on the floor
	if is_on_floor():
		df_wings_deployed = false
	else: # Gravity
		v.y += G*delta
		
		# If dragonfly wings are deployed, limit vertical velocity for slow fall
		if DRAGONFLY_MODE and df_wings_deployed:
			v.y = clamp(v.y, -179769e308, MAX_FALL_V)
	
	if SQUIRREL_MODE and is_on_wall():
		v = Vector2()

# Changes linear velocity v to make character jump
func jump() -> void:
	if is_on_floor():
		# Set basic jump speed
		v.y = -JUMP
		# If we have goat parts, allow multiple jumps
		if GOAT_MODE: 
			gt_jumps_left = GT_NUM_JUMPS
		
		# If we have cricket parts, add to jump strength
		if CRICKET_MODE:
			v.y -= CRICKET_JUMP
	elif GOAT_MODE and gt_jumps_left > 0: # not on floor, goat mode and jumps left!'
		# If we're off the ground, but have goat jumps left, we can jump again!
		gt_jumps_left = gt_jumps_left - 1
		v.y = -JUMP
		if CRICKET_MODE:
			v.y -= CRICKET_JUMP

func brake(delta : float) -> void:
	var brake_dir := -sign(v.x)
	var brake_amt : float = H_BRAKE
	if not is_on_floor():
		brake_amt = H_BRAKE_AIR
		if df_wings_deployed:
			brake_amt = DF_BRAKE_AIR
			
	v.x += brake_dir*brake_amt*delta
	
	if is_on_floor() and v.x != 0 and $AnimationPlayer.current_animation != "Brake":
		$AnimationPlayer.play("Brake")

func stop():
	if $AnimationPlayer.current_animation != "Stand":
		$AnimationPlayer.play("Stand")

func move_dir_change(dir : bool):
	for sprite in get_children():
		if sprite is Sprite:
			sprite.flip_h = dir
	
	if $AnimationPlayer.current_animation != "Run":
		$AnimationPlayer.play("Run")


