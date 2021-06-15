extends CanvasLayer


func _process(t):
	self.offset = get_node("../MapLayer").offset
	self.scale = get_node("../MapLayer").scale
