extends CardLocation
class_name CardPile
export var hotkey = ""
var ondisplay =false
const xsep = 150
const ysep = 220
var dispcards = []
var tempthings = []
const fancyfont =preload("res://Fonts/AlMadiri.tres")
const plainfont =preload("res://Fonts/Mada.tres")
var frontofdisplay:CanvasLayer

func _ready() -> void:
	self.base_z=106
	frontofdisplay = CanvasLayer.new()
	frontofdisplay.layer = 2
	frontofdisplay.scale=self.scale
	add_child(frontofdisplay)
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
			display()
		else:
			get_node("../CardPileDisplay").undisplay()

func updateDisplay():
	for thing in frontofdisplay.get_children():
		thing.queue_free()
	tempthings = []
	if not ondisplay:
		for card in cards:
			card.moveTo($AnimatedSprite.position , Vector2(.15,.15), false)
		get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"
	else:
		var startx= 30
		var x = startx
		var y = 20-get_node("../CardPileDisplay/Panel/VScrollBar").value 
		var dispcards = cards.duplicate()
		dispcards.sort_custom(self,"alphabetize")
		dispcards = removeDuplicates(dispcards)
		for pair in dispcards:
			var card = pair[0]
			card.set_process(true)
			card.moveTo(Vector2(x,y), Vector2(.2,.2))
			card.visible = true
			card.updateDisplay()
			x+=xsep
			if pair[1] > 1:
				var text = RichTextLabel.new()
				frontofdisplay.add_child(text)
				tempthings.append(text)
				text.bbcode_enabled = true
				print(str(pair[1]))
				text.bbcode_text = "[center]x " + str(pair[1] )+ " [/center]"
				text.rect_size = Vector2(xsep*2,ysep*2)
				text.rect_scale = Vector2(.4,.4)
				text.rect_position = Vector2(x,y+ysep*.25)
				text.visible = true
				text.scroll_active = false
				text.add_color_override("Default", Color(1,1,1) )
				text.add_font_override("normal_font",fancyfont)
				x+=xsep
				
			if x > startx + xsep*7:
				x = startx
				y += ysep

func display():
		$Label.visible=false
	#if get_parent().takeFocus(self):
		get_node("../CardPileDisplay").display(self)
		self.ondisplay = true
		self.updateDisplay()
	#get_parent().releaseFocus(self)
func undisplay():		
	get_node("../CardPileDisplay").undisplay()
	self.ondisplay = false
	self.updateDisplay()

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
func removeDuplicates(array):
	var ret = []
	for card in array:
		var found = false
		for pair in ret:
			if card.isIdentical(pair[0]):
				pair[1]+=1
				found  = true
				break
		if not found:
			ret.append([card, 1])
	return ret
				
		
