extends CardLocation
class_name CardPile
export var hotkey = ""
var ondisplay =false
const xsep = 150
const ysep = 220

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(hotkey):
		display()


func updateDisplay():
	if not ondisplay:
		for card in cards:
			card.moveTo($AnimatedSprite.position - Vector2(100,300), Vector2(.15,.15), false)
			card.z_index = 0
		get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"
	else:
		var startx= 200
		var x = startx
		var y = 100
		var dispcards = cards.duplicate()
		dispcards.sort_custom(self,"alphabetize")
		for card in dispcards:
			card.moveTo(Vector2(x,y), Vector2(.2,.2))
			card.visible = true
			card.z_index = 7
			card.updateDisplay()
			x+=xsep
			if x > startx + xsep*10:
				x = startx
				y += ysep


	
func display():
	#if get_parent().takeFocus(self):
		get_node("../CardPileDisplay").display(self)
		self.ondisplay = true
		self.updateDisplay()
	#get_parent().releaseFocus(self)
func undisplay():
	#get_parent().releaseFocus(self)
	self.ondisplay = false
	self.updateDisplay()

func alphabetize(card1,card2):
	if card1.title < card2.title:
		return true
	return false

	
