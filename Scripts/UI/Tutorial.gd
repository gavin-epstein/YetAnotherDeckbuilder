extends Node2D
var curFrame =1
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		doGoNext()


func _on_Skip_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		self.queue_free()

func goNext(event: InputEvent):
	if event.is_action_pressed("left_click"):
		doGoNext()
func goBack(event:InputEvent):
	if event.is_action_pressed("left_click"):
		doGoNext(-1)
	
func doGoNext(inc=1):
		get_node(str(curFrame)).visible = false
		curFrame +=inc
		if curFrame > 11 or curFrame <0:
			self.queue_free()
		else:
			get_node(str(curFrame)).visible = true



