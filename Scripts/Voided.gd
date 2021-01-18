extends CardLocation

func updateDisplay():
	for card in cards:
		card.visible = false
		card.moveTo($Sprite.position,$Sprite.scale)
	get_node("Count").bbcode_text = "[center]"+str(cards.size())+"[/center]"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
