extends Node2D
class_name CardLocation
var EnchantersWorkshop;
var ondisplay =false
#var ondisplaystartx = 0;
#var ondisplaystarty = 0;
const xsep = 190
const ysep = 220
var tempthings = []
var dispcards = []
#var frontofdisplay
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
#	frontofdisplay = CanvasLayer.new()
#	frontofdisplay.layer = 2
#	frontofdisplay.scale=self.scale
#	add_child(frontofdisplay)
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
		if card== null: #onieromancy or enchanter
			card =get_parent().Library.cardtemplate.instance()
			card.title = savecard.title
			card.controller = get_parent().cardController
			card.loadFromSave(savecard)
			if savecard.modifiers.has("onieromancy"):
				onieromancy.generateImage(card)
			elif savecard.modifiers.has("enchanters"):
				if EnchantersWorkshop == null:
					EnchantersWorkshop = load("res://Scripts/Puzzles/EnchantersWorkshop.gd").new()
					EnchantersWorkshop.loadImages()
				EnchantersWorkshop.recoverImage(card)
		else:
			card.loadFromSave(savecard)
		add_child(card)
		cards.append(card)
	updateDisplay()
		
func cardClicked(card):
	if card.highlighted:
		get_parent().cardClicked(card)

func undisplay():		
	get_node("../CardPileDisplay").undisplay()
	self.ondisplay = false
	self.updateDisplay()		
