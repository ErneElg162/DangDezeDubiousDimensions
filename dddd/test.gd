extends Node3D

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Global.w += Global.sensitivity
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Global.w -= Global.sensitivity
