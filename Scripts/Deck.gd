extends CardLocation


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func updateDisplay():
	for card in cards:
		card.visible = false
		card.moveTo($AnimatedSprite.position)
	get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
