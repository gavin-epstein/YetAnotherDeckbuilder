extends Node2D
const SAVE_NAME = "res://Saves/savefile.json"
const mainscene = preload("res://MainScene.tscn")
func savefound()-> bool:
	var file = File.new()
	return file.file_exists(SAVE_NAME)

func _on_NewGameButton_gui_input(event: InputEvent) -> void:
	$Menu/NewGame.modulate=Color(.8,.8,.8)
	if event.is_action_pressed("left_click"):
		if savefound():
			var dir = Directory.new()
			dir.remove(SAVE_NAME)
		get_tree	().change_scene_to(mainscene)


func _on_ContinueButton_gui_input(event: InputEvent) -> void:
	$Menu/Continue.modulate=Color(.8,.8,.8)
	if event.is_action_pressed("left_click"):
		if savefound():
			get_tree().change_scene_to(mainscene)

func _on_QuitButton_gui_input(event: InputEvent) -> void:
	$Menu/Quit.modulate = Color(.7,.7,.7)
	if event.is_action_pressed("left_click"):
		get_tree().quit()



func _on_QuitButton_mouse_exited() -> void:
	$Menu/Quit.modulate = Color(1,1,1)


func _on_ContinueButton_mouse_exited() -> void:
	$Menu/Continue.modulate=Color(1,1,1)


func _on_NewGameButton_mouse_exited() -> void:
	$Menu/NewGame.modulate=Color(1,1,1)
