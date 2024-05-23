extends Panel

@onready var sc_line : LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/SC_LineEdit
@onready var cc_line : LineEdit = $MarginContainer/VBoxContainer/HBoxContainer/CC_LineEdit
@onready var LastFired : Label = $MarginContainer/VBoxContainer/LastFired
@export var id : int

var key : String = ""
var value : String = ""
var command_pair : Dictionary = {"":""}

func update_text(sc : String, cc : String):
	sc_line.text = sc
	key = sc
	
	cc_line.text = cc
	value = cc

func update_fired():
	var date = Time.get_datetime_dict_from_system()
	LastFired.text = "Last Fired: " + str(date["month"]) + "/" + str(date["day"]) + "/" + str(date["year"]) + " at " + str(date["hour"]) + ":" + str(date["minute"])

func _on_delete_button_pressed():
	CommandMapper.command_dict.erase(str(id))
	CommandMapper.save_commands("user://last_saved_commands.conf")
	
	self.queue_free()


func _on_sc_line_edit_text_changed(new_text):
	key = new_text
	command_pair = {key : value}
	CommandMapper.command_dict[str(id)] = command_pair
	CommandMapper.save_commands("user://last_saved_commands.conf")


func _on_cc_line_edit_text_changed(new_text):
	value = new_text
	command_pair = {key : value}
	CommandMapper.command_dict[str(id)] = command_pair
	CommandMapper.save_commands("user://last_saved_commands.conf")
