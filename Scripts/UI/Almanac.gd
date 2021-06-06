extends Node2D
var pagetemplate = preload("res://Glossary/Page.tscn")
var terms
var library = {}
var cardLibrary
var unitLibrary
func _ready() -> void:
	$CanvasLayer/Menu.set_focus_neighbour(MARGIN_TOP,"../LineEdit")
	cardLibrary = CardLibrary.new()
	unitLibrary = UnitLibrary.new()
	cardLibrary.loadTooltips("res://CardToolTips/cardtooltips.txt")
	unitLibrary.loadIcons("res://Images/StatusIcons/",unitLibrary.icons)
	unitLibrary.loadIcons("res://Images/IntentIcons/",unitLibrary.intenticons)
	unitLibrary.loadtooltips("res://Units/tooltips.txt")
	unitLibrary.loadintenttooltips("res://Images/IntentIcons/intentTooltips.txt")
	self.Load(cardLibrary,unitLibrary)
func Load(incardLibrary, inunitLibrary):
	cardLibrary = incardLibrary
	unitLibrary = inunitLibrary
	for tooltip in cardLibrary.tooltips.keys():
		var page = pagetemplate.instance()
		page.createByText(tooltip.capitalize(), "Keyword on Cards\n"+cardLibrary.tooltips[tooltip].strip_edges())
		library[tooltip.capitalize()] = page
	for tooltip in unitLibrary.tooltips.values():
		var page = pagetemplate.instance()
		var title = tooltip.split(":")[0]
		var text  = tooltip.split(":")[1]
		page.createByText(title.capitalize(), "Status Effect\n"+text.strip_edges())
		library[title] = page
	makehyperlinks()
func getPageByName(name:String):
	return library.get(name)

func findSearchTerm(string:String):
	var terms = []
	for key in library.keys():
		for word in key.split(" "):
			if word.to_lower().substr(0,string.length()) == string.to_lower():
				if not key in terms:
					terms.append(key)
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

func displayPage(title):
	print(title)
	if title in library:
		for child in $CanvasLayer/Pages.get_children():
			$CanvasLayer/Pages.remove_child(child)
		$CanvasLayer/Pages.add_child(library[title])
func makehyperlinks():
	for page in library.values():
		var out = ""
		for word in page.text.split(" "):
			var procword = word.rstrip(".,;:\"'").to_lower().capitalize()
			if procword in library.keys() and page.title!=procword:
				print(procword)
				out+= '[url='+ procword+'][color=#ffae00]'+word+'[/color][/url]'+ " "
			else:
				out+=word+" "
		page.setText(out)
