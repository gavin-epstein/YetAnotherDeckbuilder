extends Node2D
var pagetemplate = preload("res://Glossary/Page.tscn")
var terms
var library = {}
var cardLibrary
var unitLibrary
var stack =[]
var stackindex = -1
var cardtooltipicons={}
signal Closed
func _ready() -> void:
	$CanvasLayer/LineEdit.caret_blink = true
	$CanvasLayer/Menu.set_focus_neighbour(MARGIN_TOP,"../LineEdit")
	print("spacecheck ", " "==" ") 
	#cardLibrary = CardLibrary.new()
#	unitLibrary = UnitLibrary.new()
#	cardLibrary.loadIcons()
#	cardLibrary.loadTooltips("res://CardToolTips/cardtooltips.txt")
#	unitLibrary.loadIcons("res://Images/StatusIcons/",unitLibrary.icons)
#	unitLibrary.loadIcons("res://Images/IntentIcons/",unitLibrary.intenticons)
#	unitLibrary.loadtooltips("res://Units/tooltips.txt")
#	unitLibrary.loadintenttooltips("res://Images/IntentIcons/intentTooltips.txt")
#	self.Load(cardLibrary,unitLibrary)
	
func Load(parent):
	cardLibrary = parent.cardController.Library
	unitLibrary = parent.enemyController.get_node("UnitLibrary")
	unitLibrary.loadIcons("res://CardToolTips/Tooltipimages/",cardtooltipicons) 
	#basics
	
	var page = pagetemplate.instance()
	page.createByImage("Card Basics","res://Glossary/Cards.png")
	library["Card basics"] = page
	page = pagetemplate.instance()
	page.createByImage("Unit Basics","res://Glossary/Units.png")
	library["Unit basics"] = page
	var homepage = pagetemplate.instance()
	homepage.createByText("Basics", "Overview:\n    Card Basics\n    Unit Basics");
	library["Homepage"] = homepage
	for tooltip in cardLibrary.tooltips.keys():
		page = pagetemplate.instance()
		var img = null
		if tooltip.capitalize() in cardtooltipicons.keys():
			img = cardtooltipicons[tooltip.capitalize()]
		page.createByText(tooltip.capitalize(), "Keyword on Cards\n"+cardLibrary.tooltips[tooltip].strip_edges(), img)
		library[tooltip.capitalize()] = page
		
	for tooltip in unitLibrary.tooltips.keys():
		page = pagetemplate.instance()

		var title = unitLibrary.tooltips[tooltip].split(":")[0]
		var text = unitLibrary.tooltips[tooltip].split(":")[1]
		var image =  unitLibrary.icons[tooltip]
		page.createByText(title.capitalize(), "Status Effect\n"+text.strip_edges(), image)
		library[title.capitalize()] = page
	loadTypeDescriptions("res://CardToolTips/typeDescriptions.txt")
	makehyperlinks()
	displayPage("Homepage")

	$CanvasLayer/LineEdit.grab_focus()
func getPageByName(name:String):
	return library.get(name)

func findSearchTerm(string:String):
	var terms = []
	for key in library.keys():
		for word in key.split(" "):
			if word.to_lower().substr(0,string.length()) == string.to_lower():
				if not key in terms:
					terms.append(library[key].title)
	terms.sort()
	return terms
func _on_LineEdit_text_changed(new_text: String) -> void:
	$CanvasLayer/Menu.clear()
	terms = findSearchTerm(new_text)
	for term in terms:
		$CanvasLayer/Menu.add_item(term)
	$CanvasLayer/Menu.popup(Rect2(1462,76,1143,2500))
	$CanvasLayer/LineEdit.grab_focus()

func _on_Menu_index_pressed(index: int) -> void:
	$CanvasLayer/LineEdit.text = ""
	displayPage(terms[index])

func displayPage(title,allowforward=false):
	#print(title)
	if title in library:
		for child in $CanvasLayer/Pages.get_children():
			$CanvasLayer/Pages.remove_child(child)
		$CanvasLayer/Pages.add_child(library[title])
		if stackindex < stack.size()-1 and not allowforward:
			stack = stack.slice(0,stackindex)
		if not allowforward:
			stack.append(title)
			stackindex+=1
	else:
		print("Page not found     " + title)
func makehyperlinks():
	for page in library.values():
		
		var out = ""
		for word in page.text.split(" "):
			var procword = word.rstrip(".,;:\"'").to_lower().capitalize()
			if procword in library.keys() and page.title!=procword:
				#print(procword)
				out+= '[url='+ procword+'][color=#ffae00]'+word+'[/color][/url]'+ " "
			else:
				out+=word+" "
		page.setText(out)
func loadTypeDescriptions(fname):
	var f = File.new()
	f.open(fname, File.READ)
	if !f.is_open():
		print("Failed to open "+ fname)
		return 0
	while not f.eof_reached():
		var line = f.get_line()
		if line.find(":") != -1:
			line = Array(line.split(":"))
			var title = line[0].capitalize()
			var text = "Card Type\n"+Utility.join(":", line.slice(1,line.size()-1))
			text = text.replace("\\n","\n")
			var image = cardLibrary.icons.get(title.capitalize())
			var page = pagetemplate.instance()
			page.createByText(title.capitalize(), text.strip_edges(), image)
			library[title.capitalize()] = page
	f.close()


func _on_X_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		emit_signal("Closed")
		self.queue_free()


func _on_back_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		print("back", stackindex)
		if stackindex > 0:
			displayPage(stack[stackindex-1],true)
			stackindex-=1

func _on_next_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		print("next", stackindex, stack)
		if stackindex < stack.size()-1:
			stackindex+=1
			displayPage(stack[stackindex],true)
			
