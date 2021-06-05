extends CanvasLayer
var inputallowed = true
signal startload
func startloading():
	inputallowed= false
	$ColorRect/Loading.visible=true
	$ColorRect/Question.visible=false
	$ColorRect/Panel.visible=false
	$ColorRect/Panel2.visible=false
	emit_signal("startload")


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_node("/root/Scene").doTutorial = true
		startloading()
	


func _on_Panel2_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		startloading()
