extends CardLocation
var xsep = 100
var ysep = 150

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func updateDisplay():
	var startx= 300
	var x = startx
	var y = 750
	for card in cards:
		card.moveTo(Vector2(x,y), Vector2(.15,.15))
		card.visible = true
		card.z_index = 0
		card.updateDisplay()
		x+=xsep
		if x > startx + xsep*13:
			x = startx
			y += ysep
			
func cardClicked(card):
	if card.highlighted:
		get_parent().cardClicked(card)
