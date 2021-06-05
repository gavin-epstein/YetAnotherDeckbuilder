extends CardPile




func _on_Area_gui_input(event: InputEvent) -> void:
	$Label.visible=true
	if event.is_action_pressed("left_click"):
		display()


func _on_Area_mouse_exited() -> void:
	$Label.visible=false
