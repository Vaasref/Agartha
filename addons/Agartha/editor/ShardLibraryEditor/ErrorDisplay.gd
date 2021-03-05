tool
extends Label


func _on_script_error(error):
	self.text = error
	_on_visibility_changed()

func _on_visibility_changed():
	if self.text:
		self.visible = true
