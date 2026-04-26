extends Control

@export var slider: VSlider

func _process(delta: float) -> void:
	slider.set_value_no_signal(Global.w)
