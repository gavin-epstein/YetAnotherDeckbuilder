extends Node2D
class_name CardLocation

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var cards = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
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
	assert(cards.size()>i, "No Card at %d"%i)
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
		cards: savecards
	}
func loadFromSave(save:Dictionary):
	self.cards = []
	for savecard in save.cards:
		var card = get_parent().Library.getCardByName(savecard.title)
		card.loadFromSave(savecard)
		cards.append(card)
