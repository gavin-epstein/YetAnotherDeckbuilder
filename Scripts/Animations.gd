extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func Play(animation,speed):
	
	if animation =="" or speed >10 :
		get_parent().remove_child(self)
		self.queue_free()
	$AnimationPlayer.speed_scale = speed
	$AnimationPlayer.play(animation)
	yield($AnimationPlayer,"animation_finished")
	get_parent().remove_child(self)
	self.queue_free()
