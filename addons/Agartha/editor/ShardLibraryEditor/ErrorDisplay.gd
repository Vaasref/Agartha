tool
extends Label


func _on_script_error(error):
	self.text = error
