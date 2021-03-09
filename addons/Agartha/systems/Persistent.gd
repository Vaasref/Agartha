extends Node

var persistent_state:StoreState = StoreState.new()

const path = "res://saves/persistent.tres"


func init():
	load_persistent()


func save_persistent():
	if ResourceSaver.save(path, persistent_state) != OK:
		push_error("Error when saving persistent date")


func load_persistent():
	if ResourceLoader.exists(path):
		persistent_state = ResourceLoader.load(path, "", true) as StoreState


func set_value(name, value):
	persistent_state.set(name, value)
	save_persistent()


func get_value(name):
	return persistent_state.get(name)

func has_value(name):
	return persistent_state.has(name)
