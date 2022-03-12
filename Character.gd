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
export (int) var jumps_left = 0

# Declare member variables here. Examples:
var v : Vector2 = Vector2(0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# If the snap vector hits the ground, the character will remain in contact with the ground
	var SNAP_VECTOR := Vector2.DOWN * 100

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			# If the snap vector is nothing, it does not hit the ground
			# and it allows the character to jump
			SNAP_VECTOR = Vector2()
			# Set basic jump speed
			v.y = -JUMP
			if GOAT_MODE:
				jumps_left = GT_NUM_JUMPS
			if CRICKET_MODE:
				v.y -= CRICKET_JUMP
		elif GOAT_MODE and jumps_left > 0: # not on floor, goat mode and jumps left!'
			jumps_left = jumps_left - 1
			v.y = -JUMP
			if CRICKET_MODE:
				v.y -= CRICKET_JUMP
			
	
	
	if Input.is_action_just_pressed("ui_down") and not is_on_floor():
		df_wings_deployed = not df_wings_deployed
	
	
	if Input.is_action_pressed("ui_left"):
		v.x = clamp(v.x - H_ACCEL*delta, -MAX_H_VEL, 1.79769e308)
	#elif v.x < 0 and not Input.is_action_pressed("ui_right"):
	#	v.x = clamp(v.x + H_BRAKE*delta, -1.79769e308, 0)
		
	if Input.is_action_pressed("ui_right"):
		v.x = clamp(v.x + H_ACCEL*delta, -1.79769e308, MAX_H_VEL)
	#elif v.x > 0 and not Input.is_action_pressed("ui_left"):
	#	v.x = clamp(v.x - H_BRAKE*delta, 0, 179769e308)
	
	# If no input, apply braking force
	if not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		var brake_dir := -sign(v.x)
		var brake_amt : float = H_BRAKE
		if not is_on_floor():
			brake_amt = H_BRAKE_AIR
			print("before")
			if df_wings_deployed:
				print("here")
				brake_amt = DF_BRAKE_AIR
				
		v.x += brake_dir*brake_amt*delta
		
	if (abs(v.x) < 2):
		v.x = 0
	
	v = move_and_slide_with_snap(v, SNAP_VECTOR, Vector2.UP)
	if is_on_floor():
		v.y = 0
		df_wings_deployed = false
	else:
		v.y += G*delta
		if (df_wings_deployed):
			v.y = clamp(v.y, -179769e308, MAX_FALL_V)
