extends CanvasLayer
onready var splashscene = load("res://Splash.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		show()

func show() -> void:
	$Back.visible = true
	get_tree().paused = true
func hide()->void:
	$Back.visible = false
	get_tree().paused = false


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



