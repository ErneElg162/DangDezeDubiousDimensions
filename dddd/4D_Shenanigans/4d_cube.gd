extends StaticBody3D

@export var mesh: MeshInstance3D
@export var col: CollisionShape3D
@export var width: float
@export var w_cent: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dist = abs(w_cent - Global.w)
	
	if dist <= width:
		col.disabled = false
		
	else:
		col.disabled = true
		
	if dist <= width:
		mesh.transparency = 0
		
	elif dist <= width + Global.threshold:
		mesh.transparency = (dist - width) / Global.threshold
		
	else:
		mesh.transparency = 1
