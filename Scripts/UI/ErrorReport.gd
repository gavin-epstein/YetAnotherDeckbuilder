extends CanvasLayer
const DEFAULT_TEXT = "What was the issue?"

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextEdit.text = DEFAULT_TEXT
	$OptionButton.add_item("Card not working")
	$OptionButton.add_item("Unit not working")
	$OptionButton.add_item("User Interface issues")
	$OptionButton.add_item("Something is too strong")
	$OptionButton.add_item("Something is too weak")
	$OptionButton.add_item("Game Crash")
	$OptionButton.add_item("Other")


func _on_TextEdit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click")or event.is_action_pressed("right_click"):
		if $TextEdit.text == DEFAULT_TEXT:
			$TextEdit.text = ""


func _on_CancelButton_pressed() -> void:
	get_tree().paused=false
	global.addLog("click", "error_report_cancel")
	self.queue_free()


func _on_SubmitButton_pressed() -> void:
	global.addLog("click", "error_report_submit")
	print("Submitting")
	var type = getType($OptionButton.get_selected_id())
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_onResponse")
	var body = $TextEdit.text
	var error = http_request.request("https://moraandtheendoftheworld.com/reports.php?type="+str(type), ["Content-type:text/plain"], true, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("An error occurred in the HTTP request.")
	print(error)
	get_tree().paused=false
	yield(http_request,"request_completed")
	print("response")
	self.queue_free()
func getType(input):
	if input == 0:
		return "CARDERR"
	if input ==1:
		return "UNITERR"
	if input ==2:
		return "UI"
	if input ==3:
		return "PLSNERF"
	if input ==4:
		return "PLSBUFF"
	if input ==5:
		return "CRASH"
	if input ==6:
		return "OTHER"

