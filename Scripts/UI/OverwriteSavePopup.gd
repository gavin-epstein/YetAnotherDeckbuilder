extends ColorRect


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func check():
	self.visible=true
	



func _on_Yes_gui_input(event: InputEvent) -> void:
	$Yes.modulate=Color(.8,.8,.8)
	if event.is_action_pressed("left_click") and self.visible:
		get_parent().newGame()



func _on_Yes_mouse_exited() -> void:
	$Yes.modulate=Color(1,1,1)
	

func _on_No_gui_input(event: InputEvent) -> void:
	$No.modulate=Color(.8,.8,.8)
	if event.is_action_pressed("left_click") and self.visible:
		self.visible=false


func _on_No_mouse_exited() -> void:
	$No.modulate=Color(1,1,1)
