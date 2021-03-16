extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_Panel_gui_input(event: InputEvent) -> void:
	$Panel/Panel.modulate = Color(1,1,1)
	if event.is_action_pressed("left_click"):
		self.visible = false

func _on_Panel_mouse_exited() -> void:
	$Panel/Panel.modulate = Color(.7,.7,.7)
