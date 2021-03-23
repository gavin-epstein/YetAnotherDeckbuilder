extends Node2D
var loadingscreen
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadingscreen = load("res://Splash.tscn")
	setEnemy( get_node("/root/global").lossImage)
func setEnemy(image) -> void:
	$Sprite.texture = image
	var _imagescale = 600.0/max(image.get_width(), image.get_height())
	$Sprite.scale = Vector2(_imagescale,_imagescale)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		toMainMenu()

func _on_ColorRect2_gui_input(event: InputEvent) -> void:
	$MapBackground2/ColorRect2.modulate = Color(.7,.7,.7);
	if (event.is_action_pressed("left_click")):
		toMainMenu()
	
	
func toMainMenu():
	get_tree().change_scene_to(loadingscreen)


func _on_ColorRect2_mouse_exited() -> void:
	$MapBackground2/ColorRect2.modulate = Color(1,1,1);
