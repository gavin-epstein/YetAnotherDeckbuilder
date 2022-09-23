extends Node2D
var caller
var oldinputallowed
var tempthings

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func display(caller):
	if self.caller!=null:
		undisplay()
	self.caller = caller
	$Panel.visible=true
	oldinputallowed = get_parent().inputAllowed
	get_parent().inputAllowed = false
	var vertsize = caller.cards.size()*(240/8)
	$Panel/VScrollBar.value = 0
	if vertsize > 900:
		$Panel/VScrollBar.visible=true
		$Panel/VScrollBar.max_value = vertsize
	else:
		$Panel/VScrollBar.visible=false
	
func _on_Resume_gui_input(event: InputEvent) -> void:
	if (event.is_action_pressed("left_click")):
		undisplay()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		self.undisplay()
	
func multidisplay(members):
	var x = 30;
	var y = 20;
	for pile in members:
		pass
		pile.ondisplaystarty = y
		y = pile.displayAsPile();
		var text = RichTextLabel.new()
		text.bbcode_enabled = true
		text.bbcode_text = "[center] " + pile.name+ " [/center]"
		text.rect_size = Vector2(4* CardPile.xsep, CardPile.ysep )
		text.rect_scale = Vector2(.4,.4)
		text.rect_position = Vector2(x,y)
		y += CardPile.ysep*2
		text.visible = true
		text.scroll_active = false
		text.add_color_override("Default", Color(1,1,1) )
		text.add_font_override("normal_font",CardPile.fancyfont)
		$Panel/frontofdisplay.add_child(text)

	$Panel.visible=true
	oldinputallowed = get_parent().inputAllowed
	get_parent().inputAllowed = false

	$Panel/VScrollBar.value = 0
	if y > 900:
		$Panel/VScrollBar.visible=true
		$Panel/VScrollBar.max_value = y
	else:
		$Panel/VScrollBar.visible=false
	
func clear():
	for thing in $Panel/frontofdisplay.get_children():
		thing.queue_free()
	tempthings = []
		
	
func undisplay():
	$Panel.visible = false
	if self.caller!=null:
		var temp = caller
		caller= null
		temp.undisplay()
	get_parent().inputAllowed = oldinputallowed
	
