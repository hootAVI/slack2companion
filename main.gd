extends Control

@onready var listening_line : LineEdit = $TabContainer/Main/Main_VBox/VPair1/LineEdit
@onready var pushing_edit : LineEdit = $TabContainer/Main/Main_VBox/VPair2/LineEdit
@onready var timer_edit : SpinBox = $TabContainer/Main/Main_VBox/VPair3/SpinBox
@onready var toggle_button : Button = $TabContainer/Main/Main_VBox/StartStop
@onready var throbber : TextureProgressBar = $TabContainer/Main/Main_VBox/VPair3/TextureProgressBar
@onready var timer : Timer = $Utility/Timer
@onready var HTTPListener : HTTPRequest = $Utility/HTTPListener
@onready var HTTPPusher : HTTPRequest = $Utility/HTTPPusher
@onready var ListenerOutput : TextEdit = $TabContainer/Main/Main_VBox/HBoxContainer/ListenerOutput
@onready var PusherOutput : TextEdit = $TabContainer/Main/Main_VBox/HBoxContainer/PusherOutput
@onready var new_incoming : Label = $TabContainer/Main/Main_VBox/HBoxContainer2/NewIncoming
@onready var new_outgoing : Label = $TabContainer/Main/Main_VBox/HBoxContainer2/NewOutgoing

var listening_address : String
var pushing_address : String
var timer_length : float = 1.0

var toggle_state : bool = false
var stopped_color : Color = Color("ff8983")
var started_color : Color = Color("82ff88")

var last_command : String
var last_sender : String

var tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	change_state()
	listening_address = listening_line.text
	pushing_address = pushing_edit.text
	timer_length = timer_edit.value

func _on_start_stop_toggled(toggled_on : bool):
	toggle_state = toggled_on
	change_state()
	
func _on_spin_box_value_changed(value : float):
	timer_length = value
	timer.set_wait_time(timer_length)

func change_state():
	match toggle_state:
		false:
			toggle_button.set_self_modulate(stopped_color)
			toggle_button.text = "Stopped"
			timer.stop()
			if tween:
				tween.kill()
			throbber.value = 0.0

		true:
			toggle_button.set_self_modulate(started_color)
			toggle_button.text = "Started"
			anim_throbber()
			timer.start()

func anim_throbber():
	if tween:
		tween.kill()
	throbber.value = 0.0
	tween = get_tree().create_tween()
	tween.tween_property(throbber, "value", 100, timer_length).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func _on_timer_timeout():
	anim_throbber()
	try_listen()
	
func try_listen():
	if HTTPListener.get_http_client_status() != 0:
		HTTPListener.cancel_request()
	#HTTPListener.request(listening_address)
	var error = HTTPListener.request(listening_address, [], HTTPClient.METHOD_POST)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func _on_http_listener_request_completed(result, response_code, headers, body):
	if body.size() > 2 or result == 999:
		var body_json
		if result == 999:
			body_json = body
		else:
			if JSON.parse_string(body.get_string_from_utf8()):
				body_json = JSON.parse_string(body.get_string_from_utf8())[0]
			else:
				return

		last_command = body_json["command"]
		last_sender = body_json["user_name"]
		ListenerOutput.text = "USER: " + last_sender + "\nCOMMAND: " + last_command
		
		new_incoming.set_self_modulate(Color("ffffffff"))
		var tween = get_tree().create_tween()
		tween.tween_property(new_incoming, "self_modulate", Color("ffffff00"), 1.0)
		
		translate_to_output()

func translate_to_output():
	var outgoing_command : String = "null"
	
	#match last_command:
		#"/lights-on":
			#pass
		#"/lights-off":
			#pass
		#"/backup-record":
			#outgoing_command = "/api/custom-variable/BackupRecord/value?value=1"
		#"/backup-stop":
			#outgoing_command = "/api/custom-variable/BackupRecord/value?value=0"


	for i in CommandMapper.command_dict:
		if last_command in CommandMapper.command_dict[i]:
			print("command " + str(last_command) + " found in " + str(CommandMapper.command_dict[i]))
			print("CC should be: " + str(CommandMapper.command_dict[i].values()[0]))
			outgoing_command = CommandMapper.command_dict[i].values()[0]
			
			for x in CommandMapper.command_mapping_screen_ref.command_holder.get_children():
				if str(x.id) == i:
					x.update_fired()
			
			new_outgoing.set_self_modulate(Color("ffffffff"))
			var tween = get_tree().create_tween()
			tween.tween_property(new_outgoing, "self_modulate", Color("ffffff00"), 1.0)

			PusherOutput.text = "COMMAND: " + last_command + "\nAPI CALL: " + pushing_address + outgoing_command
			var error = HTTPListener.request(pushing_address + outgoing_command, [], HTTPClient.METHOD_POST)
			if error != OK:
				push_error("An error occurred in the HTTP request.")
			return
	
	PusherOutput.text = "Slack Command " + str(last_command) + " has no API call mapping.\nGo to the Command Mapper and map it!"

func _on_lightson_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/lights-on","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_lightsoff_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/lights-off","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_video_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/backup-record","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_audio_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/backup-stop","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_weenio_pressed():
	var temp : Dictionary = {"api_app_id":"A063NTQB51D","channel_id":"C063NTX2ENT","channel_name":"arl_prod","command":"/weenio","is_enterprise_install":"false","response_url":"https://hooks.slack.com/commands/T037Z7J1A02/7132084952514/prbxRsn3aWjsCBUMrH1rzjSx","team_domain":"coe22","team_id":"T037Z7J1A02","text":"","token":"RfkJYEx8Jcu3qxVzcrydlC0Y","trigger_id":"7134560157748.3271256044002.47b469f6426391d9b2d2724a7dec1bed","user_id":"U05HDAFHWJU","user_name":"debugman"}
	_on_http_listener_request_completed(999, null, null, temp)

func _on_tab_container_tab_changed(tab):
	if tab == 2:
		$TabContainer/Debugging.update_logs()
