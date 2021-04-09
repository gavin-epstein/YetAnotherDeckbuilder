extends Node2D
const fancyfont =preload("res://Fonts/AlMadiri.tres")
const plainfont =preload("res://Fonts/Mada.tres")

func updateDisplay(unit, library):
	for child in $TextContainer.get_children():
		$TextContainer.remove_child(child)
		child.queue_free()
	var pos = Vector2(0,0)
	
	var text = RichTextLabel.new()
	text.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	var lines
	if unit != unit.controller.Player:
		var speedrange = ""
		speedrange += "Speed: "+str(unit.speed)
		if unit.attackrange>0:
			speedrange+=", Range "+ str(unit.attackrange)+". "
			speedrange+="This unit can attack if it starts its turn within "+str(max(unit.speed,1)+unit.attackrange-1)+" tiles" 
		text = RichTextLabel.new()
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$TextContainer.add_child(text)
		lines =  ceil(speedrange.length()/29.0)
		text.bbcode_text = speedrange
		text.bbcode_enabled = true
		text.rect_size = Vector2(2100,170*lines)
		text.rect_scale = Vector2(.5,.5)
		text.rect_position = pos
		text.visible = true
		text.scroll_active = false
		text.add_font_override("normal_font",plainfont)
		pos +=Vector2(0,85*lines + 40)
	if unit.intents.size()>0:
		var intents = []
		for intent in unit.intents:
			if intent in library.intenttooltips:
				intents.append(library.intenttooltips[intent])
		var intentstring = "This unit intends to "
		if intents.size()>1:
			intents[intents.size()-1] = "and " + intents[intents.size()-1]
		intentstring+=Utility.join(", ",intents)
		text = RichTextLabel.new()
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$TextContainer.add_child(text)
		lines =  ceil(intentstring.length()/29.0)
		text.bbcode_text = intentstring
		text.bbcode_enabled = true
		text.rect_size = Vector2(2100,170*lines)
		text.rect_scale = Vector2(.5,.5)
		text.rect_position = pos
		text.visible = true
		text.scroll_active = false
		text.add_font_override("normal_font",plainfont)
		pos +=Vector2(0,85*lines + 40)
	
	if unit.lore !=null:
		text = RichTextLabel.new()
		text.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$TextContainer.add_child(text)
		lines =  ceil(unit.lore.length()/29.0)
		text.bbcode_text = unit.lore
		text.bbcode_enabled = true
		text.rect_size = Vector2(2100,170*lines)
		text.rect_scale = Vector2(.5,.5)
		text.rect_position = pos
		text.visible = true
		text.scroll_active = false
		text.add_font_override("normal_font",plainfont)
		pos +=Vector2(0,85*lines + 40)
	
	var status = unit.status.duplicate()
	if unit.armor !=0:
		status["armor"]= unit.armor
	if unit.block!=0:
		status["block"]= unit.block
	
	for stat in status:
		if stat in library.icons and stat in library.tooltips:
			var sprite = Sprite.new()
			$TextContainer.add_child(sprite)
			sprite.texture = library.icons[stat]
			sprite.visible=true
			sprite.position = pos+Vector2(50,90)
			sprite.scale = Vector2(.25,.25)
			text = RichTextLabel.new()
			text.mouse_filter = Control.MOUSE_FILTER_IGNORE
			$TextContainer.add_child(text)
			var content = library.tooltips[stat]
			lines =  ceil(content.length()/25.0)
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
