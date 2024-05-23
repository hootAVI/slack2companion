extends MarginContainer

@onready var command_line_scene = preload("res://Scenes/CommandLine/command_line.tscn")
@onready var command_holder = $Main_VBox/CommandScroller/CommandHolder
@onready var export_dialog = $Main_VBox/SaveLoad_HBox/Export/ExportDialog
@onready var import_dialog = $Main_VBox/SaveLoad_HBox/Import/ImportDialog

#TODO add a "defaults" button that overwrites "last_saved_commands" with the first time user dictionary.
#TODO add a universal error window to prevent stupid mistakes like the default button, or deleting a command

func _ready():
	CommandMapper.command_mapping_screen_ref = self
	CommandMapper.load_commands("user://last_saved_commands.conf")
	


func add_command_line(sc:String, cc:String, id:String):
	var new_command = command_line_scene.instantiate()
	new_command.id = id
	command_holder.add_child(new_command)
	new_command.update_text(sc, cc)

func _on_button_pressed():
	var id = str(randi())
	add_command_line("", "", id)
	CommandMapper.add_command("", "", id)

func _on_default_button_pressed():
	if ErrorHandling.selection_made.is_connected(popup_import):
		ErrorHandling.selection_made.disconnect(popup_import)
	ErrorHandling.selection_made.connect(set_defaults)
	ErrorHandling.new_twobutton_window("Restore Defaults", "Would you like to replace all currently mapped commands with the defaults?\n(Not undo-able)", "Yes", "No")

func set_defaults(selection):
	match selection:
		0:
			print("no")
		1:
			print("yes")
			CommandMapper.save_defaults()
			for i in command_holder.get_children():
				i.queue_free()
			CommandMapper.load_commands("user://last_saved_commands.conf")


func _on_export_pressed():
	export_dialog.popup()


func _on_export_dialog_file_selected(path):
	var test : String
	if path.ends_with(".conf"):
		test = path
	else:
		test = path + ".conf"
	CommandMapper.save_commands(test)

func _on_import_pressed():
	if ErrorHandling.selection_made.is_connected(set_defaults):
		ErrorHandling.selection_made.disconnect(set_defaults)
	ErrorHandling.selection_made.connect(popup_import)
	ErrorHandling.new_twobutton_window("Import Mapping", "Importing a custom mapping will overwrite your current mapping.\nContinue?", "Yes", "No")

func popup_import(selection):
	match selection:
		0:
			print("no")
		1:
			print("yes")
			import_dialog.popup()

func _on_import_dialog_file_selected(path):
	for i in CommandMapper.command_mapping_screen_ref.command_holder.get_children():
		i.queue_free()
	CommandMapper.load_commands(path)
