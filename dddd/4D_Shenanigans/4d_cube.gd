extends StaticBody3D

@export var mesh: MeshInstance3D
@export var col: CollisionShape3D
@export var width: float
@export var w_cent: float

var wobble_duration: float = 0.5

var material: ShaderMaterial
var wobble_time: float = 0.0
var is_wobbling: bool = false

func _ready() -> void:
	material = mesh.get_active_material(0) as ShaderMaterial

func wobble(delta: float):
	if not is_wobbling:
		return
	
	wobble_time += delta
	var progress: float = wobble_time / wobble_duration
	
	if progress >= 1.0:
		progress = 1.0
		is_wobbling = false
	
	material.set_shader_parameter("amount", progress)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dist = abs(w_cent - Global.w)
	
	if dist <= width:
		if col.disabled:
			wobble_time = 0.0
			is_wobbling = true
			
			col.disabled = false
		
	else:
		col.disabled = true
		
	if dist <= width:
		visible = true
		mesh.transparency = 0
		
	elif dist <= width + Global.threshold:
		visible = true
		mesh.transparency = (dist - width) / Global.threshold
		
	else:
		mesh.transparency = 1
		visible = false
		
	wobble(delta)
