extends CardLocation
const boxysep = 425/.4*.35

func updateDisplay():
	if cards.size() == 0:
		get_node("../createbutton").visible=false
		return
	get_node("../createbutton").visible = true
	var pos = Vector2(0,0)
	for card in cards:
		card.visible = true
		card.z_index = 0
		card.updateDisplay()
		card.moveTo(pos, Vector2(.35,.35))
		move_child(card, get_child_count()-1)
		pos += Vector2(0,boxysep)
		if pos.y >= 1080 - boxysep:
			pos = Vector2(290, 0)
			
		
func clear():
	for card in get_children():
		remove_child(card)
		card.queue_free()
	cards = []
