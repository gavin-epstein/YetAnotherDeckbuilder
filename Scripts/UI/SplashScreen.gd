extends Node2D
const SAVE_NAME = "user://savefile.json"
const mainscene = preload("res://MainScene.tscn")
func _ready() -> void:
	var screensize = OS.get_screen_size()
	OS.set_window_size(screensize)

func savefound()-> bool:
	var file = File.new()
	return file.file_exists(SAVE_NAME)

func _on_NewGameButton_gui_input(event: InputEvent) -> void:
	$Menu/NewGameButton.modulate=Color(.8,.8,.8)
	if event.is_action_pressed("left_click"):
		if savefound():
			$OverwriteSavePopup.check()
		else:
			newGame()
			
func newGame():
	var dir = Directory.new()
	dir.remove(SAVE_NAME)
	get_tree	().change_scene_to(mainscene)


func _on_ContinueButton_gui_input(event: InputEvent) -> void:
	$Menu/ContinueButton.modulate=Color(.8,.8,.8)
	if event.is_action_pressed("left_click"):
		if savefound():
			get_tree().change_scene_to(mainscene)
		else:
			$NoSaveFound.visible=true

func _on_QuitButton_gui_input(event: InputEvent) -> void:
	$Menu/QuitButton.modulate = Color(.7,.7,.7)
	if event.is_action_pressed("left_click"):
		get_tree().quit()



func _on_QuitButton_mouse_exited() -> void:
	$Menu/QuitButton.modulate = Color(1,1,1)


func _on_ContinueButton_mouse_exited() -> void:
	$Menu/ContinueButton.modulate=Color(1,1,1)


func _on_NewGameButton_mouse_exited() -> void:
	$Menu/NewGameButton.modulate=Color(1,1,1)

#func _input(event: InputEvent) -> void:
#	print(event.as_text())


func _on_SettingsButton_gui_input(event: InputEvent) -> void:
	$Menu/SettingsButton.modulate = Color(.7,.7,.7)
	if (event.is_action_pressed("left_click")):
		$Settings.visible=true

func _on_SettingsButton_mouse_exited() -> void:
	$Menu/SettingsButton.modulate=Color(1,1,1)
