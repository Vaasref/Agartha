tool
extends MarginContainer

signal open_library(library, _clear_editor)
signal use_shortcut(shortcut)

func open_library(library:ShardLibrary):
	self.emit_signal("open_library", library, true)


func _on_use_shortcut(shortcut):
	self.emit_signal('use_shortcut', shortcut)


func _on_new_shard_library(new_library):
	print("New library saved")
	self.emit_signal("open_library", new_library, false)
