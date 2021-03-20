extends CardPile


func add_card(card) -> void:
	if cards.size() == 0:
		add_card_at(card,0)
	else:
		add_card_at(card,randi()%cards.size())
	


func _on_Area2_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		display()
