extends Control
	
@onready var http_line_edit = $VBoxContainer/PostRequest_LineEdit
@onready var http_output_log = $VBoxContainer/PostRequest_Log
@onready var command_output_log = $VBoxContainer/LogHolder/CommandOutput

func update_logs():
	if CommandMapper.command_dict.size() > 0:
		command_output_log.text = JSON.stringify(CommandMapper.command_dict, "\t")

func _on_button_pressed():
	$HTTPRequest.cancel_request()
	$HTTPRequest.request(http_line_edit.text, [], HTTPClient.METHOD_POST)
	http_output_log.text = "COMMAND: " + http_line_edit.text + "\n Waiting for reply..."


func _on_http_request_request_completed(result, response_code, headers, body):
	http_output_log.text = "COMMAND: " + http_output_log.text + "\n"
	http_output_log.text += "RESULT: " + str(result) + "\nRESPONSE_CODE: " + str(response_code) + "\nHEADERS: " + str(headers) + "\nBODY: " + str(body) + "\nBODY (utf8): " + str(body.get_string_from_utf8())
