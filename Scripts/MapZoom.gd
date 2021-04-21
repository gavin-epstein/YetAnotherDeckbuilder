extends CanvasLayer
const zoomspeed = 1
const scrollspeed = 30
const scrollerpspeed = 2
const zoomamount = 1.07
var zoomfactor = 1.0
var targetpos= Vector2(960,410)
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
func _input(event: InputEvent) -> void:
	if event.is_action("zoom_in"):
		zoom(zoomamount)
	elif event.is_action("zoom_out"):
		zoom(1.0/zoomamount)
	elif event is InputEventMagnifyGesture:
		zoom(event.factor)
	elif event.is_action("ui_right"):
		scroll(Vector2(-1*scrollspeed,0))
	elif event.is_action("ui_down"):
		scroll(Vector2(0,-1*scrollspeed))
	elif event.is_action("ui_left"):
		scroll(Vector2(scrollspeed,0))
	elif event.is_action("ui_up"):
		scroll(Vector2(0,scrollspeed))
	elif event is InputEventPanGesture:
		scroll(-2.5*event.delta)
func _process(delta: float) -> void:
	var _sc = lerp(self.scale.x,zoomfactor,delta*zoomspeed)
	self.scale = Vector2(_sc,_sc)
	self.offset = lerp(self.offset, self.targetpos,scrollerpspeed*delta)
	
func zoom(amount):
	var oldzoomfactor = zoomfactor
	zoomfactor = clamp(zoomfactor*amount,.5,2)
	var scalechange = oldzoomfactor- zoomfactor
	#targetpos.x += 960 *scalechange
	#targetpos.y += 410*scalechange
	
func scroll(amount):
	var zfsquared  = zoomfactor*zoomfactor
	targetpos.x = clamp(targetpos.x + amount.x, 960-200*zfsquared, 960+200*zfsquared)
	targetpos.y = clamp(targetpos.y + amount.y, 410-300*zfsquared, 410+300*zfsquared)
