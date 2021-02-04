extends Node2D
const xdiff = 1162-478
const font =preload("res://Fonts/AlMadiri.tres")

func updateDisplay(statuses:Dictionary,icons:Dictionary):
	var pos = Vector2(-1162,817)
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for status in statuses:
		if status in icons:
			var sprite = Sprite.new()
			
			add_child(sprite)
			sprite.texture = icons[status]
			sprite.visible=true
			sprite.position = pos
			sprite.z_index = -1
			var val  = statuses[status]
			if val is int:
				print("Adding val "+ str(val))
				var text = RichTextLabel.new()
				add_child(text)
				text.text = str(val)
				text.rect_size = Vector2(260,174)
				text.rect_scale = Vector2(3,3)
				text.rect_position = pos+Vector2(180,0)
				text.visible = true
				text.modulate = Color(.5,.5,.5)
				text.add_font_override("normal_font",font)
				
			pos += Vector2(xdiff, 0)
			if pos.x > (xdiff * 6)-1162:
				pos.y-=xdiff*5.5
				pos.y+=600
		
