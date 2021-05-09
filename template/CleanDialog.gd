extends ConfirmationDialog
class_name CleanDialog

func _ready():
	remove_child(get_close_button())
	get_close_button().queue_free()
	get_label().align = Label.ALIGN_CENTER
	
	get_ok().text = "Yes"
	get_ok().use_parent_material = true
	
	get_cancel().text = "No"
	get_cancel().use_parent_material = true
	
	for c in get_children():
		if c is CanvasItem:
			c.use_parent_material = true
