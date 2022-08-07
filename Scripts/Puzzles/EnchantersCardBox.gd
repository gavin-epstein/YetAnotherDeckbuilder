extends CardLocation
const ysep = 425/.4*.35

func updateDisplay():
	if cards.size() == 0:
		return
	var pos = Vector2(0,0)
	for card in cards:
		card.visible = true
		card.z_index = 0
		card.updateDisplay()
		card.moveTo(pos, Vector2(.35,.35))
		move_child(card, get_child_count()-1)
		pos += Vector2(0,ysep)
		if pos.y >= 1080 - ysep:
			pos = Vector2(290, 0)
			
		
func clear():
	for card in get_children():
		remove_child(card)
		card.queue_free()
	cards = []
