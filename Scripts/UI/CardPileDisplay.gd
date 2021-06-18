extends Node2D
var caller
var oldinputallowed
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
	

func undisplay():
	$Panel.visible = false
	if self.caller!=null:
		var temp = caller
		caller= null
		temp.undisplay()
	get_parent().inputAllowed = oldinputallowed
	
