extends Node2D
var caller
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func display(caller):
	if self.caller!=null:
		undisplay()
	self.caller = caller
	$Panel.visible=true
	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$Panel/Resume.mouse_filter =Control.MOUSE_FILTER_STOP
func _on_Resume_gui_input(event: InputEvent) -> void:
	if (event.is_action_pressed("left_click")):
		undisplay()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		self.undisplay()
	

func undisplay():
	$Panel.visible = false
	if self.caller!=null:
		self.caller.undisplay()
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Panel/Resume.mouse_filter =Control.MOUSE_FILTER_IGNORE
