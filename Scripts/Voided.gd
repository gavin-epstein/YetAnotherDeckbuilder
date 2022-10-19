extends CardPile


func _on_Area_gui_input(event: InputEvent) -> void:
	$Label.visible=true
	if event.is_action_pressed("left_click"):
		global.addLog("click", "burn")
		display(30,30)


func _on_Area_mouse_exited() -> void:
	global.addLog("endhover", "burn")
	$Label.visible=false


func _on_Area_mouse_entered() -> void:
	global.addLog("beginhover", "burn")
