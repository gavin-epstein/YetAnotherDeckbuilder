extends CardPile




func _on_Area_gui_input(event: InputEvent) -> void:
	$Label.visible=true
	if event.is_action_pressed("left_click"):
		global.addLog("click", "deck")
		display(20,20)


func _on_Area_mouse_exited() -> void:
	global.addLog("endhover", "discard")
	$Label.visible=false


func _on_Area_mouse_entered() -> void:
	global.addLog("beginhover", "discard")
