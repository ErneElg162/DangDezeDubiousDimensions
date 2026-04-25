extends Node3D

@export var wobble_duration: float = 0.5

var material: ShaderMaterial
var wobble_time: float = 0.0
var is_wobbling: bool = false

@onready var mesh = $MeshInstance3D

func _ready() -> void:
	material = mesh.get_active_material(0) as ShaderMaterial

func trigger_wobble() -> void:
	wobble_time = 0.0
	is_wobbling = true

func _process(delta: float) -> void:
	
	if not is_wobbling:
		return
	
	wobble_time += delta
	var progress: float = wobble_time / wobble_duration
	
	if progress >= 1.0:
		progress = 1.0
		is_wobbling = false
	
	material.set_shader_parameter("amount", progress)
