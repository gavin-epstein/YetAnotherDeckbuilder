extends CardLocation
class_name CardPile
export var hotkey = ""



func add_card_at(card, i)->void:
	cards.insert(i, card)
	if card.get_parent()!=null:
		card.get_parent().remove_child(card)
	add_child(card)

#func _process(delta: float) -> void:
#	if(ondisplay and randf() < .1):
#		updateDisplay()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(hotkey):
		if not ondisplay:
			display(30,20)
		else:
			undisplay()

func updateDisplay():
	if not ondisplay:
		for card in cards:
			card.moveTo($AnimatedSprite.position , Vector2(.15,.15), false)
		get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"

		

func display(x,y):
		$Label.visible=false
		get_node("../CardPileDisplay").display(self)
		return self.updateDisplay()

	#get_parent().releaseFocus(self)


func alphabetize(card1,card2):
	if card1.highlighted and not card2.highlighted:
		return true
	elif not card1.highlighted and  card2.highlighted:
		return false
	if card1.title < card2.title:
		return true
	if card1.title == card2.title:
		for v in card1.vars.keys():
			if v in card2.vars:
				if card1.vars[v]>card2.vars[v]:
					return true
		for m in card1.modifiers:
			if not m in card2.modifiers:
				return true
	return false
