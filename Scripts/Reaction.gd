extends CardLocation

func updateDisplay():
	for card in cards:
		card.visible = false
		card.moveTo($AnimatedSprite.position)
	get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"

func add_card(card) -> void:
	if cards.size() == 0:
		add_card_at(card,0)
	else:
		add_card_at(card,randi()%cards.size())
	
