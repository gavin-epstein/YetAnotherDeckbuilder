extends Node2D
export var charge:int = 2;
export var capacity:int = 4;
var BatteryFull = preload("res://Images/UIArt/BatteryFull.png")
var BatteryEmpty = preload("res://Images/UIArt/BatteryEmpty.png")
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateDisplay()
	
func updateDisplay():
	for child in get_children():
		if child.name != "ColorRect2":
			child.queue_free();
	var charged = 0
	for i in range(max(0,min(capacity,10))):
		var img
		if charged < self.charge:
			img = BatteryFull
			charged +=1
		else:
			img = BatteryEmpty
		
		var sprite = Sprite.new()
		sprite.texture = img
		add_child(sprite)
		move_child(sprite, 0)
		sprite.position = Vector2(0, -135*i)
	if capacity >=10:
		$ColorRect2/RichTextLabel.bbcode_text = "[center]" +str(charge) + "/" + str(capacity)+"[/center]";
		$ColorRect2.visible = true
	else:
		$ColorRect2.visible = false
			
