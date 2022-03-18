extends Control

export (float, 0, 0.15) var SECONDS_PER_CHARACTER := 0.05 # Seconds per character
var _tlc := 0.0 # Time since last character

var paused := false
var _line := 0

var characters = {}
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_size = Vector2( OS.get_screen_size().x, 200)
	$BG/RichTextLabel.visible_characters = 0
	
	load_diag_from_file("res://dialogue/meet_squirrel.txt")
	
	$AnimationPlayer.play("wiggle")
	
func load_diag_from_file(file_location : String) -> void:
	var file := File.new()
	if file.open("res://dialogue/meet_squirrel.txt", file.READ) == OK:
		var content = file.get_as_text()
		file.close()
	
		load_diag_from_JSON(JSON.parse(content).result)
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
		queue_free()
		return
	
	$BG/RichTextLabel.bbcode_text = lines[_line]["text"]
	$BG/RichTextLabel.visible_characters = 0
	
	switch_speaker_sprite()
	
	paused = false

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
	if paused:
		if Input.is_action_just_pressed("ui_accept"):
			go_to_line(_line + 1)
		return
	
	
	_tlc = _tlc + delta
	if _tlc > SECONDS_PER_CHARACTER:
		_tlc = _tlc - SECONDS_PER_CHARACTER
		$BG/RichTextLabel.visible_characters = $BG/RichTextLabel.visible_characters + 1
		if $BG/RichTextLabel.percent_visible >= 1:
			paused = true
