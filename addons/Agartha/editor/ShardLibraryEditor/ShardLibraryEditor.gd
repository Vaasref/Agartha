tool
extends MarginContainer

signal open_library(library)
signal use_shortcut(shortcut)

func open_library(library:ShardLibrary):
	self.emit_signal("open_library", library)


func _on_use_shortcut(shortcut):
	self.emit_signal('use_shortcut', shortcut)
