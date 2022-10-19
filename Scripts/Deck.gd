extends CardPile


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func add_card(card) -> void:
	if cards.size() == 0:
		add_card_at(card,0)
	else:
		add_card_at(card,randi()%cards.size())
	



func _on_Area_gui_input(event: InputEvent) -> void:
	$Label.visible=true
	if event.is_action_pressed("left_click"):
		global.addLog("click", "deck")
		display(50,50)

func _on_Area_mouse_exited() -> void:
	global.addLog("endhover", "deck")
	$Label.visible=false


func _on_Area_mouse_entered() -> void:
	global.addLog("beginhover", "deck")
