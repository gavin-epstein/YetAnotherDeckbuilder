extends CollisionShape2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
signal onClick(pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftClick"):
		global.addLog("click", "map")
		emit_signal("onClick", event.position-(get_viewport_rect().size/2))
