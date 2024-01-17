extends Sprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.



func _on_Area2D_input_event(event: InputEvent) -> void:
	print("whee")
	if event.is_action_pressed("left_click"):
		get_parent().createcards()
