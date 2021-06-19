extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func Play(animation):
	if animation =="":
		get_parent().remove_child(self)
		self.queue_free()
	print("anim "+animation)
	$AnimationPlayer.play(animation)
	yield($AnimationPlayer,"animation_finished")
	get_parent().remove_child(self)
	self.queue_free()
