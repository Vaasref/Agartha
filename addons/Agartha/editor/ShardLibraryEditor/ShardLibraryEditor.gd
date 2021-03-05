tool
extends MarginContainer

signal open_library(library)

func open_library(library:ShardLibrary):
	self.emit_signal("open_library", library)
