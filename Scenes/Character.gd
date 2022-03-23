extends KinematicBody2D

class_name Character

export var DEBUG := true
export var DEBUG_WARNINGS := false

enum CharacterStates {
	GROUNDED,
	JUMPING,
	WALLGRABBING
}

export (CharacterStates) var charstate = CharacterStates.GROUNDED

onready var snap_vector : Vector2 = SNAP_VECTOR

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

# External forces
var _external_forces : Array = []

# Linear velocity
var v : Vector2 = Vector2(0,0)

func _ready():
	$AnimationPlayer.play("Stand")

func _draw():
	# I think this draws collision normals?
	if get_slide_count():
		var col := get_last_slide_collision()
		draw_line(to_local(col.position), to_local(col.position + col.normal*100), Color.red,2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#update() # This triggers the _draw function	
	
	if charstate == CharacterStates.GROUNDED:
		_process_grounded(delta)
	elif  charstate == CharacterStates.JUMPING:
		_process_jumping(delta)
	elif  charstate == CharacterStates.WALLGRABBING:
		_process_wallgrabbing(delta)
	
	# APPLY EXTENRAL FORCES
	for force in _external_forces:
		v += force.get_force(self)*delta
	
	# Limit horizontal velocity
	v.x = clamp(v.x, -MAX_H_VEL, MAX_H_VEL)
	
	# Actually move the character
	v.y = move_and_slide_with_snap(v, snap_vector, Vector2.UP,true,4,deg2rad(70)).y
	
	# Determine post-movement state changes here
	if charstate != CharacterStates.GROUNDED and is_on_floor():
		land()
		
	
	if SQUIRREL_MODE and is_on_wall() and not is_on_floor():
		charstate = CharacterStates.WALLGRABBING
		v = Vector2()
	

func _process_grounded(delta) -> void:
	# Vibe check
	if not is_on_floor() and DEBUG_WARNINGS:
		print("WARNING: _process_grounded() called when not is_on_floor()")
	
	# If the snap vector intersects the ground,
	# the character will remain in contact with it when moving
	snap_vector = SNAP_VECTOR

	# JUMPING
	if Input.is_action_just_pressed("ui_up"):
		jump()
	
	# MOVING LEFT AND RIGHT
	if Input.is_action_pressed("ui_left"):
		v.x = v.x - H_ACCEL*delta
		move_dir_change(true)
	if Input.is_action_pressed("ui_right"):
		v.x = v.x + H_ACCEL*delta
		move_dir_change(false)
	
	# BRAKING
	if not Input.is_action_pressed("ui_left") and not Input.is_action_pressed("ui_right"):
		brake(delta)
	
	# BRING CHARACTER TO ABSOLUTE STOP IN HORIZONTAL DIMENSION
	if (abs(v.x) < 2) and v.x != 0:
		stop()
		v.x = 0

func _process_jumping(delta) -> void:
	# Vibe check
	if is_on_floor():
		print("WARNING: _process_jumping() called when is_on_floor()")
	
	# JUMPING
	if Input.is_action_just_pressed("ui_up"):
		jump()
	
	# DEPLOYING WINGS
	if Input.is_action_just_pressed("ui_down") and not is_on_floor():
		df_wings_deployed = not df_wings_deployed
	
	# Gravity	
	v.y += G*delta
	
	# If dragonfly wings are deployed, limit vertical velocity for slow fall
	if DRAGONFLY_MODE and df_wings_deployed:
		v.y = clamp(v.y, -179769e308, MAX_FALL_V)
	

func _process_wallgrabbing(delta) -> void:
	pass


func land() -> void:
	print("heres")
	df_wings_deployed = false
	charstate = CharacterStates.GROUNDED
	# Explicitly not setting animation this frame.
	# We let the animation be chosen next frame when _process_grounded figures
	# out whether the character is braking or moving or standing

# Changes linear velocity v to make character jump
func jump() -> void:
	
	# Check preconditions for jumping
	if not is_on_floor() and (not GOAT_MODE or gt_jumps_left <= 0):
		return
	
	# We are definitely jumping, so make sure snap vector allows
	# character to move out of contact with ground
	snap_vector = Vector2()
	
	# Set basic jump speed
	v.y = -JUMP
	
	if is_on_floor():
		# If we have cricket parts, add to jump strength
		if CRICKET_MODE:
			v.y -= CRICKET_JUMP
		# If we have goat parts, allow multiple jumps
		if GOAT_MODE: 
			gt_jumps_left = GT_NUM_JUMPS
	elif GOAT_MODE and gt_jumps_left > 0: # not on floor, goat mode and jumps left!'
		# If we're off the ground, but have goat jumps left, we can jump again!
		gt_jumps_left = gt_jumps_left - 1
		# Further jumps are also affected by cricket mode
		if CRICKET_MODE:
			v.y -= CRICKET_JUMP
	
	$AnimationPlayer.play("Jump")
	charstate = CharacterStates.JUMPING
	
func brake(delta : float) -> void:
	var brake_dir := -sign(v.x)
	var brake_amt : float = H_BRAKE
	if not is_on_floor():
		brake_amt = H_BRAKE_AIR
		if df_wings_deployed:
			brake_amt = DF_BRAKE_AIR
			
	v.x += brake_dir*brake_amt*delta
	
	if is_on_floor() and v.x < 0 and $AnimationPlayer.current_animation != "Brake_L":
		$AnimationPlayer.play("Brake_L")
	elif is_on_floor() and v.x > 0 and $AnimationPlayer.current_animation != "Brake_R":
		$AnimationPlayer.play("Brake_R")

func stop():
	if $AnimationPlayer.current_animation != "Stand":
		$AnimationPlayer.play("Stand")

func move_dir_change(left : bool):
	for sprite in get_children():
		if sprite is Sprite:
			sprite.flip_h = not left
	
	if $AnimationPlayer.current_animation != "Move":
		$AnimationPlayer.play("Move")

func add_external_force(force):
	_external_forces.append(force)

func remove_external_force(force):
	_external_forces.erase(force)

