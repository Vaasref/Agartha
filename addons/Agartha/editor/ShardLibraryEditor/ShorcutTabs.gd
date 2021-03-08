tool
extends Control

export var button:PackedScene

signal use_shortcut(shortcut)

func _on_update_shortcuts(shortcuts):
	for c in self.get_children():
		self.remove_child(c)
	
	for shortcut in shortcuts:
		if shortcut.is_abs_path():
			var filename = shortcut.get_file()
			var shortcut_button = button.instance()
			shortcut_button.text = filename
			shortcut_button.set_meta("shortcut", shortcut)
			shortcut_button.connect("use_shortcut", self, '_on_use_shortcut')
			self.add_child(shortcut_button)
	

func _on_use_shortcut(shortcut):
	self.emit_signal('use_shortcut', shortcut)
