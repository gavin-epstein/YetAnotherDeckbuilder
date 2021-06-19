extends Node2D
onready var label = $CanvasLayer/Control/RichTextLabel
var number
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	yield(get_parent(),"animateHealthChange")
	var text = ""
	if number is String:
		text = number
		label.modulate = Color(1,1,1)
	elif number > 0:
		text += "+"
		label.modulate = Color(0,.66,0)
	elif number == 0:
		label.modulate = Color(0,0,.78)
	else:
		label.modulate = Color(.78,0,0)
	text += str(number)
	label.text = text
	$AnimationPlayer.play("Dissolve")
	yield($AnimationPlayer,"animation_finished")
	self.queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
