extends CardPile




func _on_Area_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		display()
