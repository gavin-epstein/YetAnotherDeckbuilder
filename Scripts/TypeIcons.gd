extends Node2D
const ydiff = 939-123
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


func generate():
	var card = get_parent().get_parent()
	var library = card.controller.get_node("Library")
	var pos = Vector2(500,323)
	for type in card.types:
		if type in library.icons:
			var sprite = Sprite.new()
			sprite.texture = library.icons[type]
			add_child(sprite)
			
			sprite.position = pos
			pos += Vector2(0, ydiff)
			if pos.y > ydiff * 8:
				pos.y-=ydiff*7.5
				pos.x+=708
