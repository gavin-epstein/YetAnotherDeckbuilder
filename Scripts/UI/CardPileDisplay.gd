extends Node2D
var caller
var oldinputallowed
var tempthings
var curx
var cury
const startx=30
var lastscroll=0
# Declare member ariables here. Examples:
# var a: int = 2
# var b: String = "text"
func _process(delta:float) -> void:
	if caller == null:
		return
	if  abs(lastscroll - $Panel/VScrollBar.value) > .1:
		var diff = $Panel/VScrollBar.value - lastscroll;
		lastscroll =  $Panel/VScrollBar.value
		curx= startx;
		cury = 60;
		for pile in caller:
			if pile.cards.size() == 0:
				continue
			displayPile(pile, false)
			cury +=CardPile.ysep*1.3
		$Panel/frontofdisplay.position += Vector2(0, -1*diff);
func display(caller):
	return multidisplay([caller])
#	if self.caller!=null:
#		undisplay()
#	self.caller = caller
#	$Panel.visible=true
#	oldinputallowed = get_parent().inputAllowed
#	get_parent().inputAllowed = false
#	var vertsize = caller.cards.size()*(240/8)
#	$Panel/VScrollBar.value = 0
#	if vertsize > 900:
#		$Panel/VScrollBar.visible=true
#		$Panel/VScrollBar.max_value = vertsize
#	else:
#		$Panel/VScrollBar.visible=false
	
func _on_Resume_gui_input(event: InputEvent) -> void:
	if (event.is_action_pressed("left_click")):
		undisplay()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		self.undisplay()
	elif event is InputEventPanGesture:
		$Panel/VScrollBar.value += -2.5*event.delta.y
	elif event.is_action_pressed("ui_down"):
		$Panel/VScrollBar.value +=CardPile.ysep *.5
	elif event.is_action_pressed("ui_up"):
		$Panel/VScrollBar.value -=CardPile.ysep *.5

func multidisplay(members):
	oldinputallowed = get_parent().inputAllowed
	clear()
	caller = members
	curx= startx;
	cury = 60;
	for pile in members:
		if pile.cards.size() == 0:
			continue
		displayPile(pile)
		cury +=CardPile.ysep*1.3

	$Panel.visible=true
	
	get_parent().inputAllowed = false

	$Panel/VScrollBar.value = 0
	if cury > 900:
		$Panel/VScrollBar.visible=true
		$Panel/VScrollBar.max_value = cury
	else:
		$Panel/VScrollBar.visible=false
func displayPile(pile:CardLocation, textmode = true):
	curx = startx
	pile.base_z = 106
	pile.ondisplay = true
	if textmode:
		var text = RichTextLabel.new()
		text.bbcode_enabled = true
		text.bbcode_text = "[center] " + pile.name+ " [/center]"
		text.rect_size = Vector2(4* CardPile.xsep, CardPile.ysep )
		text.rect_scale = Vector2(.3,.3)
		text.rect_position = Vector2(curx,cury)
		text.visible = true
		text.scroll_active = false
		text.add_color_override("Default", Color(1,1,1))
		text.add_font_override("normal_font",CardPile.fancyfont)
		$Panel/frontofdisplay.add_child(text)
	
	cury += CardLocation.ysep*.25
#	var y = ondisplaystarty-get_node("../CardPileDisplay/Panel/VScrollBar").value 
	var dispcards = pile.cards.duplicate()
	dispcards.sort_custom(self,"alphabetize")
	dispcards = removeDuplicates(dispcards)
	for pair in dispcards:
		var card = pair[0]
		card.set_process(true)
		Utility.cardMoveToAbsolute(card, Vector2(curx, cury-$Panel/VScrollBar.value), Vector2(.25, .25))
		card.visible = true
		card.updateDisplay()
		curx+=CardPile.xsep
		if pair[1] > 1:
			if textmode:
				var text = RichTextLabel.new()
				$Panel/frontofdisplay.add_child(text)
				text.bbcode_enabled = true
				#print(str(pair[1]))
				text.bbcode_text = "[center]x " + str(pair[1] )+ " [/center]"
				text.rect_size = Vector2(CardPile.xsep*2,CardPile.ysep*2)
				text.rect_scale = Vector2(.5,.5)
				text.rect_position = Vector2(curx, cury+CardPile.ysep*.25)
				text.visible = true
				text.scroll_active = false
				text.add_color_override("Default", Color(1,1,1) )
				text.add_font_override("normal_font",CardPile.fancyfont)
			curx+=CardPile.xsep
			
		if curx > startx + CardPile.xsep*7:
			curx = startx
			cury += CardPile.ysep

	
func clear():
	for thing in $Panel/frontofdisplay.get_children():
		thing.queue_free()
	tempthings = []
		
	
func undisplay():
	if caller ==null:
		return false #already closed
	$Panel.visible = false
	for pile in caller:
		pile.ondisplay=false
		pile.updateDisplay()
	caller=null
	get_parent().inputAllowed = oldinputallowed
	
func removeDuplicates(array):
	var ret = []
	for card in array:
		var found = false
		for pair in ret:
			if card.isIdentical(pair[0]):
				pair[1]+=1
				found  = true
				break
		if not found:
			ret.append([card, 1])
	return ret
