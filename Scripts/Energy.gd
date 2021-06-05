extends AnimatedSprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func updateDisplay():
	$Count.bbcode_text = "[center]"+str(get_parent().Energy)+"[/center]"




func _on_Area_mouse_entered() -> void:
	$Label.visible = true




func _on_Area_mouse_exited() -> void:
	$Label.visible = false
