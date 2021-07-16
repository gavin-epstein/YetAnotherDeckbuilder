extends HSlider

func _ready() -> void:
	value = (4-global.animationspeed)

func _on_HSlider_value_changed(value: float) -> void:
	global.animationspeed = 4-value
	global.emit_signal("animspeedchanged", 4-value)
	
