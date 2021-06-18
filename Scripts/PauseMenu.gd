extends CanvasLayer
const errortemplate = preload("res://Images/UIArt/ErrorReport.tscn")
onready var splashscene = load("res://Splash.tscn")
onready var almanactemplate = preload("res://Glossary/Almanac.tscn")
onready var buttons =[$Back/Resume,$Back/Resign,$Back/SaveQuit,$Settings]
signal unpaused
func _input(event: InputEvent) -> void:
	if get_parent().loaded:		
		if event.is_action_pressed("escape"):
			show()
		elif event.is_action_pressed("error_report"):
			var error = errortemplate.instance()
			add_child(error)
			get_tree().paused = true

func show() -> void:
	$Back.visible = true
	get_tree().paused = true
func hide()->void:
	$Back.visible = false
	get_tree().paused = false
	emit_signal("unpaused")


func _ResumeButton(event: InputEvent) -> void:

	if event.is_action_pressed("left_click"):
		hide()
func _SaveQuitButton(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_parent().save()
		hide()
		get_tree().change_scene_to(splashscene)
func _ResignButton(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		hide()
		get_parent().deletesave()
		get_tree().change_scene_to(splashscene)


func _on_Settings_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		$Settings.visible=true


func _on_Almanac_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var almanac = almanactemplate.instance()
		almanac.Load(get_node("/root/Scene"))
		add_child(almanac)
		yield(almanac, "Closed")
		hide()
