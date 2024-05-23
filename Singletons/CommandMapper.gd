extends Node

var command_mapping_screen_ref
var command_dict : Dictionary = {}
#command_id(int): {slack_command(string) : companion_command(string)}

	#TODO - Make it so commands are saved to disk every time a command_line is changed
	# Also make it so on first launch, a set of default commands are saved

func load_commands(filepath):
	if FileAccess.file_exists(filepath):
		print("file found")
		var file = FileAccess.open(filepath, FileAccess.READ)
		var content = file.get_as_text()
		command_dict = JSON.parse_string(content)
		file.close()

	else:
		print("no file found")
		save_defaults()
		
	for i in command_dict:
		command_mapping_screen_ref.add_command_line(command_dict[i].keys()[0], command_dict[i].values()[0], str(i))

func save_commands(filepath):
	print("saved")
	print(command_dict)
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_line(JSON.stringify(command_dict))
	file.close()

func save_defaults():
	command_dict = {
		"1":
			{"/lights-on":"/api/custom-variable/LightStatus/value?value=1"},
		"2":
			{"/lights-off":"/api/custom-variable/LightStatus/value?value=0"},
		"3":
			{"/backup-record":"/api/custom-variable/BackupRecord/value?value=1"},
		"4":
			{"/backup-stop":"/api/custom-variable/BackupRecord/value?value=0"}
	}
	save_commands("user://last_saved_commands.conf")

func add_command(slack_command : String, companion_command : String, command_id : String):
	var command_pair : Dictionary = {slack_command : companion_command}
	command_dict[int(command_id)] = command_pair
	save_commands("user://last_saved_commands.conf")
