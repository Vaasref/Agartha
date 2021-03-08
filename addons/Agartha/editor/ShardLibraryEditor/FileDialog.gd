tool
extends FileDialog

var ShardParser = preload("res://addons/Agartha/systems/ShardParser.gd")
var parser = ShardParser.new()

signal insert_shard_script(script)

var shard_library


enum Mode{
	SAVE_NEW_LIBRARY,
	INSERT,
	IMPORT_INPUT,
	IMPORT_OUTPUT,
	EXPORT
}
var current_mode:int

const shard_filter:Array = ["*.shrd ; Shard script"]
const library_filter:Array = ["*.tres ; Godot resource"]

func _on_open_library(library):
	self.shard_library = library


func _on_Insert_pressed():
	self.mode = FileDialog.MODE_OPEN_FILES
	self.filters = shard_filter
	current_mode = Mode.INSERT
	self.window_title = "Select shard script file(s) to insert."
	self.popup_centered()


func _on_Import_pressed():
	self.mode = FileDialog.MODE_OPEN_FILE
	self.filters = shard_filter
	current_mode = Mode.IMPORT_INPUT
	self.window_title = "Select script file to import."
	self.popup_centered()

func select_import_output():
	self.mode = FileDialog.MODE_SAVE_FILE
	self.filters = library_filter
	current_mode = Mode.IMPORT_OUTPUT
	self.window_title = "Save imported library as ..."
	self.popup_centered()

func _on_Export_pressed():
	if shard_library:
		self.mode = FileDialog.MODE_SAVE_FILE
		self.filters = shard_filter
		current_mode = Mode.EXPORT
		self.window_title = "Export library to ..."
		self.popup_centered()


func _on_file_selected(path):
	match current_mode:
		Mode.IMPORT_INPUT:
			temp_import_input_path = path
			self.call_deferred('select_import_output')
		Mode.IMPORT_OUTPUT:
			import_library(temp_import_input_path, path)
		Mode.EXPORT:
			export_library(path)
		Mode.SAVE_NEW_LIBRARY:
			save_library(path)



var temp_import_input_path

func import_library(script_path, library_path):
	var f = File.new()
	
	f.open(script_path, File.READ)
	var file_text = f.get_as_text()
	if not file_text.ends_with('\n'):
		file_text += '\n'
	f.close()
	
	var new_library = ShardLibrary.new()
	var new_library_script = parser.parse_shard(file_text)
	new_library.save_script(new_library_script)
	
	var error = ResourceSaver.save(library_path, new_library)
	if error:
		push_error("Error when saving imported shard library.")


var temp_new_library

func save_library(library_path):
	var error = ResourceSaver.save(library_path, temp_new_library)
	if error:
		push_error("Error when saving new shard library.")



func export_library(script_path):
	if not shard_library:
		return
	var f = File.new()
	
	var script = shard_library.get_shards()
	var script_text = parser.compose_shard(script)
	if not script_text.ends_with('\n'):
		script_text += '\n'
	
	f.open(script_path, File.WRITE)
	f.store_string(script_text)
	f.close()

func _on_files_selected(paths):
	if current_mode == Mode.INSERT:
		var output = ""
		var f = File.new()
		for file in paths:
			if output:
				output += '\n'
			f.open(file, File.READ)
			output += f.get_as_text()
			if not output.ends_with('\n'):
				output += '\n'
			f.close()
		self.emit_signal('insert_shard_script', output)


func _on_save_new_library(new_library):
	temp_new_library = new_library
	self.mode = FileDialog.MODE_SAVE_FILE
	self.filters = library_filter
	current_mode = Mode.SAVE_NEW_LIBRARY
	self.window_title = "Save new library as ..."
	self.popup_centered()
