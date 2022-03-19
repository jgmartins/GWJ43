tool
extends Area2D

export (float) var strength = 100 setget set_strength

onready var p : CPUParticles2D = $Particles
onready var c : CollisionShape2D = $CollisionShape2D

func _ready():
	_update_particles()

func get_force(_character) -> Vector2:
	return transform.basis_xform(Vector2.RIGHT)*strength

func _on_Wind_body_entered(body) -> void:
	if body is Character:
		body.add_external_force(self)

func _on_Wind_body_exited(body) -> void:
	if body is Character:
		body.remove_external_force(self)

func _process(_delta):
	if Engine.editor_hint:
		p = $Particles
		c = $CollisionShape2D
		_update_particles()

func _update_particles():
	if not c:
		return
	p.emission_rect_extents = c.shape.extents
	p.emission_rect_extents.x = p.emission_rect_extents.x / 2
	p.emission_rect_extents.y = p.emission_rect_extents.y
	p.position = c.position - Vector2(c.shape.extents.x/2, 0)
	p.initial_velocity = p.emission_rect_extents.x*2 / p.lifetime

func set_strength(stren : float):
	strength = stren
	_update_particles()
