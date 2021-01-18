extends CardLocation


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false


func updateDisplay():
	if cards.size() == 0:
		return
	var pos = Vector2(-300,60) + $CardChoiceBack2.position
	var xsep = 200
	for card in cards:
		card.visible = true
		card.z_index = 0
		card.moveTo(pos, Vector2(.25, .25))
		move_child(card, get_child_count()-1)
		card.updateDisplay()
		pos += Vector2(xsep,0)
func cardClicked(card):
	get_parent().move("Choice", "Hand", card)
	get_parent().Hand.updateDisplay()
	if card.modifiers.has("unique"):
		get_parent().Library.removeUnique(card.title);
	clear()
	
func clear():
	visible = false
	for card in cards:
		card.queue_free()
	cards = []
	get_parent().inputAllowed = true
	
	

func generateReward(rarity, count = 3):
	var types = []
	for card in get_parent().Play.cards:
		for type in card.types:
			types.append(type)
	if types == []:
		types = ["any"]
	for i in range(count):
		var card  = get_parent().Library.getRandom(rarity, types)
		self.add_card(card)
	self.visible = true
	self.updateDisplay()


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event.is_action("left_click"):
		clear()
