extends CardLocation


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func add_card(card) -> void:
	if cards.size() == 0:
		add_card_at(card,0)
	else:
		add_card_at(card,randi()%cards.size())
	

func updateDisplay():
	for card in cards:
		card.visible = false
		card.moveTo($AnimatedSprite.position)
	get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
