extends Node2D
class_name CardLocation
var ondisplay =false
var ondisplaystartx = 0;
var ondisplaystarty = 0;
const xsep = 150
const ysep = 220
var tempthings = []
var dispcards = []
var frontofdisplay
const fancyfont =preload("res://Fonts/AlMadiri.tres")
const plainfont =preload("res://Fonts/Mada.tres")
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var base_z = 0
var cards = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.base_z=106
	frontofdisplay = CanvasLayer.new()
	frontofdisplay.layer = 2
	frontofdisplay.scale=self.scale
	add_child(frontofdisplay)
func size()->int:
	return cards.size()
func add_card(card) -> void:
	add_card_at(card,cards.size())
	
func add_card_at(card, i)->void:
	cards.insert(i, card)
	if card.get_parent()!=null:
		card.get_parent().remove_child(card)
	add_child(card)

func remove_card(card) -> bool:
	if cards.has(card):
		cards.erase(card)
		return true
	return false
func remove_card_at(i) -> bool:
	if cards.size() <= i:
		return false
	cards.remove(i)
	return true
func getCard(i):
	#assert(cards.size()>i, "No Card at %d"%i)
	if cards.size()<=i:
		return null
	return cards[i]

func updateDisplay() -> void:
	pass
	#assert(false, "Abstract Method")
func displayAsPile():
	base_z = 106
	ondisplay = true
	var startx= ondisplaystartx
	var x = startx
	var y = ondisplaystarty-get_node("../CardPileDisplay/Panel/VScrollBar").value 
	var dispcards = cards.duplicate()
	dispcards.sort_custom(self,"alphabetize")
	dispcards = removeDuplicates(dispcards)
	for pair in dispcards:
		var card = pair[0]
		card.set_process(true)
		card.moveTo(Vector2(x*1.5/self.scale.x,y*1.5/self.scale.y), Vector2(.3/self.scale.x, .3/self.scale.y))
		card.visible = true
		card.updateDisplay()
		x+=xsep
		if pair[1] > 1:
			var text = RichTextLabel.new()
			get_parent().get_node("CardPileDisplay/Panel/frontofdisplay").add_child(text)
			self.tempthings.append(text)
			text.bbcode_enabled = true
			print(str(pair[1]))
			text.bbcode_text = "[center]x " + str(pair[1] )+ " [/center]"
			#text.rect_size = Vector2(xsep*3/self.scale.x,ysep*3/self.scale.y)
			#text.rect_scale = Vector2(.6/self.scale.x,.6/self.scale.y)
			#text.rect_position = Vector2(x*1.5/self.scale.x,(y+ysep*.25)*1.5/self.scale.y)
			text.rect_size = Vector2(xsep*3,ysep*3)
			text.rect_scale = Vector2(.6,.6)
			text.rect_position = Vector2(x*1.5,(y+ysep*.25)*1.5)
			text.visible = true
			text.scroll_active = false
			text.add_color_override("Default", Color(1,1,1) )
			text.add_font_override("normal_font",fancyfont)
			x+=xsep
			
		if x > startx + xsep*7:
			x = startx
			y += ysep
	return y
	
func save()-> Dictionary:
	var savecards = []
	for card in cards:
		if card !=null:
			savecards.append(card.save())
	return{
		"cards": savecards
	}
func loadFromSave(save:Dictionary):
	self.cards = []
	for savecard in save.cards:
		var card = get_parent().Library.getCardByName(savecard.title)
		if card== null: #onieromancy
			card =get_parent().Library.cardtemplate.instance()
			card.title = savecard.title
			card.controller = get_parent().cardController
			card.loadFromSave(savecard)
			onieromancy.generateImage(card)
		else:
			card.loadFromSave(savecard)
		add_child(card)
		cards.append(card)
	updateDisplay()
		
func cardClicked(card):
	if card.highlighted:
		get_parent().cardClicked(card)
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
func undisplay():		
	get_node("../CardPileDisplay").undisplay()
	self.ondisplay = false
	self.updateDisplay()		
