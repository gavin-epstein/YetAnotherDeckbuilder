extends Node2D
const fancyfont =preload("res://Fonts/AlMadiri.tres")
const plainfont =preload("res://Fonts/Mada.tres")

func updateDisplay(unit, library):
	for child in $TextContainer.get_children():
		$TextContainer.remove_child(child)
		child.queue_free()
	var pos = Vector2(-60,0)
	
	var text = RichTextLabel.new()
	$TextContainer.add_child(text)
	text.bbcode_text = str("[center]" + unit.title+"[/center]")
	text.bbcode_enabled = true
	text.rect_size = Vector2(1034,175)
	text.rect_scale = Vector2(1,1)
	text.rect_position = pos
	text.visible = true
	text.scroll_active = false
	pos+=Vector2(0,150)
	#text.modulate = Color(.7,.7,.7)
	text.add_font_override("normal_font",fancyfont)
	if unit.lore !=null:
		text = RichTextLabel.new()
		$TextContainer.add_child(text)
		var lines =  ceil(unit.lore.length()/29.0)
		text.bbcode_text = unit.lore
		text.bbcode_enabled = true
		text.rect_size = Vector2(2100,170*lines)
		text.rect_scale = Vector2(.5,.5)
		text.rect_position = pos
		text.visible = true
		text.scroll_active = false
		text.add_font_override("normal_font",plainfont)
		pos +=Vector2(0,85*lines + 40)
	for stat in unit.status:
		if stat in library.icons and stat in library.tooltips:
			var sprite = Sprite.new()
			$TextContainer.add_child(sprite)
			sprite.texture = library.icons[stat]
			sprite.visible=true
			sprite.position = pos+Vector2(50,90)
			sprite.scale = Vector2(.25,.25)
			text = RichTextLabel.new()
			$TextContainer.add_child(text)
			var content = library.tooltips[stat]
			var lines =  ceil(content.length()/29.0)
			text.bbcode_text = content
			text.bbcode_enabled = true
			text.rect_size = Vector2(1800,170*lines)
			text.rect_scale = Vector2(.5,.5)
			text.rect_position = pos + Vector2(146,0)
			text.visible = true
			text.scroll_active = false
			text.add_font_override("normal_font",plainfont)
			pos +=Vector2(0,85*lines + 40)
	$Background.rect_size = Vector2(1150,pos.y)
