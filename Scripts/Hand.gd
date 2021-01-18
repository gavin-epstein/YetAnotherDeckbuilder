extends CardLocation
var maxHandSize = 10

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func is_full() -> bool:
	return self.size() > maxHandSize

func updateDisplay():
	if cards.size() == 0:
		return
	var pos = Vector2(300,860)
	var xsep = min(1000/cards.size(), 150)
	for card in cards:
		card.visible = true
		card.z_index = 0
		card.moveTo(pos, Vector2(.2,.2))
		move_child(card, get_child_count()-1)
		pos += Vector2(xsep,0)
		
		
func returnCard(target):
	var pos = Vector2(0,-30)
	var xsep = min(1000/cards.size(), 150)
	for card in cards:
		if card == target:	
			card.moveTo(pos, Vector2(.2,.2))
		pos += Vector2(xsep,0)
func cardClicked(card):
	if get_parent().inputAllowed:
		get_parent().Action("play", [card])
