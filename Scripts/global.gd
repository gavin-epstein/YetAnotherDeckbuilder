extends Node
const SETTINGS = "user://settings.json"
var lossImage = preload("res://Images/UIArt/EmptyLantern.png")
var animationspeed = 1.6
var logData;

signal animspeedchanged(animationspeed)

func openLog():
	print(OS.get_user_data_dir())
	logData =  File.new()
	logData.open("user://logData"+str(OS.get_unix_time())+ ".txt", File.WRITE)
func closeLog():
	logData.close()
func addLog(action,label ):
	if logData == null:
		return
	var time = OS.get_ticks_msec()
	logData.store_string(action+";"+label+";"+ str(time)+ "\n")
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		closeLog()


func saveSettings():
	var save = {
		"sfx_volume": db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))),
		"music_volume":db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))),
		"animation_speed":animationspeed
	}
	var file = File.new()
	file.open(SETTINGS, File.WRITE)
	file.store_string(to_json(save))
	file.close()


func loadSettings():
	print("loading settings")
	var save
	var file = File.new()
	if file.file_exists(SETTINGS):
		file.open(SETTINGS, File.READ)
		if !file.is_open():
			print("Failed to open "+ SETTINGS)
			return 
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			save = data
			if "sfx_volume" in save:
				var bus = AudioServer.get_bus_index("SFX")
				var val =  linear2db(save.sfx_volume)
				AudioServer.set_bus_volume_db(bus, val)
			
			if "music_volume" in save:
				var bus = AudioServer.get_bus_index("Music")
				var val =  linear2db(save.music_volume)
				AudioServer.set_bus_volume_db(bus, val)
		
			if "animation_speed" in save:
				animationspeed = save.animation_speed
				emit_signal("animspeedchanged", animationspeed)

func endGameReport(state:String, bodyjson:String):
	yield(get_tree().create_timer(1),"timeout")
	print("Submitting")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_onResponse")
	
	var error = http_request.request("https://moraandtheendoftheworld.com/winlosereports.php?result="+state, ["Content-type:text/plain"], true, HTTPClient.METHOD_POST, bodyjson)
	if error != OK:
		print("An error occurred in the HTTP request.")
	print(error)
	#get_tree().paused=false
	yield(http_request,"request_completed")
func _onResponse(result, response_code, headers, body):
	print("Response:   ")
	print(body.get_string_from_utf8())

