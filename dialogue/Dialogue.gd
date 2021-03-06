extends Control
class_name Dialogue

export (float, 0, 0.15) var SECONDS_PER_CHARACTER := 0.05 # Seconds per character

export (String) var DIALOGUE_RESOURCE

export var run_on_start := false

var _tlc := 0.0 # Time since last character

var paused := false
var _line := 0

var characters = {}
var lines = []

signal dialogue_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_size = Vector2( OS.get_screen_size().x, 200)
	$BG/RichTextLabel.visible_characters = 0
	if DIALOGUE_RESOURCE:
		load_diag_from_file(DIALOGUE_RESOURCE)
		if run_on_start:
			start_dialogue()
	
	$AnimationPlayer.play("wiggle")

func run_diag_from_file(file_location : String) -> void:
	load_diag_from_file(file_location)
	start_dialogue()
	
func load_diag_from_file(file_location : String) -> void:
	var file := File.new()
	if file.open(file_location, file.READ) == OK:
		var content = file.get_as_text()
		file.close()
		
		var res := JSON.parse(content)
		if res.error != OK:
			print(res.error_string)
		else:
			load_diag_from_JSON(res.result)
	else:
		print("ERROR: Could not load dialogue from '%s'" % file_location)

func load_diag_from_JSON(json : Dictionary) -> void:
	characters = json["characters"]
	lines = json["lines"]
	
	# Preload textures for character display, adding them to dictionary
	for charname in characters:
		characters[charname]["texture"] = load(characters[charname]["res"])
	
	go_to_line(0)


func go_to_line(line_number : int) -> void:
	_line = line_number
	
	# If dialogue is done, we destroy this object.
	if _line >= len(lines):
		end_dialogue()
		return
	
	$BG/RichTextLabel.bbcode_text = lines[_line]["text"]
	$BG/RichTextLabel.visible_characters = 0
	
	switch_speaker_sprite()
	
	paused = false

func start_dialogue():
	visible = true
	paused = false

func end_dialogue():
	emit_signal("dialogue_ended")
	self.visible = false
	
	# Disconnect all signals
	for s in get_signal_connection_list("dialogue_ended"):
		disconnect(s.signal, s.target, s.method)

func current_character() -> Dictionary:
	return characters[lines[_line]["character"]]
	
func switch_speaker_sprite() -> void:
	var c := current_character()
	var ctr : TextureRect = $Character
	ctr.texture = c["texture"]
	ctr.rect_position = Vector2(c["position"].x, c["position"].y)
	ctr.rect_size = Vector2(c["size"].x, c["size"].y)
	ctr.flip_h = c["flip"]

func _process(delta):
	if visible == false:
		return
	
	if paused:
		if Input.is_action_just_pressed("ui_accept"):
			go_to_line(_line + 1)
		return
	
	# Not paused but key pressed, finish this line
	if Input.is_action_just_pressed("ui_accept"):
		$BG/RichTextLabel.percent_visible = 1
		paused = true
		return
	
	_tlc = _tlc + delta
	if _tlc > SECONDS_PER_CHARACTER:
		_tlc = _tlc - SECONDS_PER_CHARACTER
		$BG/RichTextLabel.visible_characters = $BG/RichTextLabel.visible_characters + 1
		if $BG/RichTextLabel.percent_visible >= 1:
			paused = true
