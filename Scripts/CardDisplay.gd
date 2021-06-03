extends Node2D
var card
const cardTemplate = preload("res://Card.tscn")
const fancyfont =preload("res://Fonts/AlMadiri.tres")
const plainfont =preload("res://Fonts/Mada.tres")

func _ready() -> void:
	self.visible = false
func display(incard):
	get_parent().releaseFocus(incard)
	get_parent().takeFocus(self)
	self.visible = true
	card = cardTemplate.instance()
	incard.deepcopy(card)
	add_child(card)
	card.mouseon=false
	card.name="Card"
	card.moveTo(Vector2(400,128.8),Vector2(.8,.8))
	var pos = Vector2(1000,150)
	var text = RichTextLabel.new()
	add_child(text)
	var typescontent = "Types: " 
	typescontent+=Utility.join(", ",card.types.keys())
	var lines =  ceil(typescontent.length()/19.6)
	text.bbcode_text = typescontent
	text.bbcode_enabled = true
	text.rect_size = Vector2(1800,170*lines)
	text.rect_scale = Vector2(.25,.25)
	text.rect_position = pos + Vector2(146,0)
	text.visible = true
	text.scroll_active = false
	text.add_font_override("normal_font",plainfont)
	pos +=Vector2(0,42*lines + 10)
	for content in card.getTooltips():
		text = RichTextLabel.new()
		add_child(text)
		lines =  ceil(content.length()/19.6)
		text.bbcode_text = content
		text.bbcode_enabled = true
		text.rect_size = Vector2(1800,170*lines)
		text.rect_scale = Vector2(.25,.25)
		text.rect_position = pos + Vector2(146,0)
		text.visible = true
		text.scroll_active = false
		text.add_font_override("normal_font",plainfont)
		pos +=Vector2(0,42*lines + 10)
	$Panel.rect_size = Vector2(600, pos.y)
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
func undisplay(): 
	get_parent().releaseFocus(self)
	self.visible = false
	card.queue_free()
	remove_child(card)
	for child in get_children():
		if child is RichTextLabel:
			child.queue_free()
			remove_child(child)
	$ColorRect.mouse_filter = Control.MOUSE_FILTER_PASS


func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") or event.is_action_pressed("right_click"):
		undisplay()
