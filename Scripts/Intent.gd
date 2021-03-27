extends Node2D
const xdiff = 700

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func updateDisplay(intents:Array,icons:Dictionary):
	var pos = Vector2(-858,-1787)
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for intent in intents:
		if intent in icons:
			
			var sprite = Sprite.new()
			
			add_child(sprite)
			sprite.texture = icons[intent]
			sprite.visible=true
			sprite.position = pos
			sprite.z_index = 1
			
			pos += Vector2(xdiff, 0)
			if pos.x > (xdiff * 8)-1838:
				pos.y-=xdiff*8
				pos.y+=900
		else:
			print ("Missing intent Icon for: " + intent)
		
