extends Node

var persistent_state = StoreState.new()

var path = "res://saves/persistent.tres"


func init():
	var compress = Agartha.Settings.get("agartha/paths/saves/compressed_permanent_data_file")
	path = Agartha.Settings.get_user_path("agartha/paths/saves/permanent_data_folder", "persistent.tres", compress)
	load_persistent()


func save_persistent():
	var error = ResourceSaver.save(path, persistent_state)
	if error != OK:
		push_error("Error when saving persistent date")


func load_persistent():
	if ResourceLoader.exists(path):
		persistent_state = load(path)


func set_value(name, value):
	persistent_state.set(name, value)
	save_persistent()


func get_value(name):
	var output = persistent_state.get(name)
	if output and output is Object and output.has_method('duplicate'):
		output = output.duplicate(true)
	return output

func has_value(name):
	return persistent_state.has(name)
