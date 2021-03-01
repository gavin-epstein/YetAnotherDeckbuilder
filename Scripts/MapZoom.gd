extends CanvasLayer
const zoomspeed = 1
const scrollspeed = 10
const scrollerpspeed = 2
const zoomamount = 1.05
var zoomfactor = 1.0
var targetpos= Vector2(0,0)
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		zoom(zoomamount)
	elif event.is_action("zoom_out"):
		zoom(1.0/zoomamount)
	elif event is InputEventMagnifyGesture:
		#zoomfactor = clamp(zoomfactor*event.factor,.5,2)
		pass
	elif event.is_action("ui_right"):
		targetpos.x = max(targetpos.x - scrollspeed, -200)
	elif event.is_action("ui_down"):
		targetpos.y = max(targetpos.y - scrollspeed, -200)
	elif event.is_action("ui_left"):
		targetpos.x = min(targetpos.x + scrollspeed, 200)
	elif event.is_action("ui_up"):
		targetpos.y = min(targetpos.y + scrollspeed, 200)
	elif event is InputEventPanGesture:
		targetpos.x = clamp(targetpos.x - 2.5*event.delta.x,-200,200)
		targetpos.y = clamp(targetpos.y - 2.5*event.delta.y,-200,200)
func _process(delta: float) -> void:
	var _sc = lerp(self.scale.x,zoomfactor,delta*zoomspeed)
	self.scale = Vector2(_sc,_sc)
	self.offset = lerp(self.offset, self.targetpos,scrollerpspeed*delta)
	
func zoom(amount):
	var oldzoomfactor = zoomfactor
	zoomfactor = clamp(zoomfactor*amount,.5,2)
	var scalechange = oldzoomfactor- zoomfactor
	targetpos.x += 960 *scalechange
	targetpos.y += 410*scalechange
	
	pass
