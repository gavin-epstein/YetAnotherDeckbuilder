extends Node2D
var caller
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func display(caller):
	self.caller = caller
	$Panel.visible=true

func _on_Resume_gui_input(event: InputEvent) -> void:
	if (event.is_action_pressed("left_click")):
		undisplay()

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept")):
		undisplay()
	elif (event.is_action_pressed("ui_cancel")):
		undisplay()

func undisplay():
	$Panel.visible = false
	self.caller.undisplay()
