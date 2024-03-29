extends Node2D
const xdiff = 1162-478
const font =preload("res://Fonts/AlMadiri.tres")
const numberbackground = preload("res://Images/StatusIcons/statusnumberback.png")

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
			if val is float:
				val = int(val)
				statuses[status] = int(val)
			if val is int:
				#Background
				sprite = Sprite.new()
				sprite.texture = numberbackground
				sprite.position = pos + Vector2(180,0)
				sprite.centered = false
				sprite.scale = Vector2(.25,.25)
				sprite.z_index = -1
				var text = RichTextLabel.new()
				text.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(text)
				text.text = str(val)
				text.rect_size = Vector2(260,174)
				text.rect_scale = Vector2(3,3)
				text.rect_position = pos+Vector2(180,0)
				text.visible = true
				#text.modulate = Color(.7,.7,.7)
				text.add_font_override("normal_font",font)
				text.scroll_active = false
			pos += Vector2(xdiff, 0)
			if pos.x > (xdiff * 6)-1162:
				pos.y-=xdiff*5.5
				pos.y+=600
		
