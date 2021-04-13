tool
extends Button
class_name SaveSlot

export var image_background_color:Color = Color.gray
var save:Resource = null
var save_filename
var save_mode

const date_format:String = "{day}/{month}/{year} {hour}:{minute}"

func init(_save_filename, _save, _save_mode):
	save_filename = _save_filename
	save_mode = _save_mode
	save = _save
	var error = Agartha.Saver.check_save_compatibility(save, false)
	if save and save is StoreSave:
		if error and error == Agartha.Saver.COMPATIBILITY_ERROR.DIFF_SCRIPT_COMP_CODE:
			init_default_screenshot()
			$Labels/Name.visible = false
			$Labels/Name.editable = false
			var file:File = File.new()
			init_date(OS.get_datetime_from_unix_time(file.get_modified_time(Agartha.Saver.get_save_path(save_filename))))
		else:
			$Screenshot.texture = save.get_screenshot_texture()
			$Labels/Name.text = save.name
			init_date(save.date)
		if error:
			$Screenshot/Error.visible = true
		
	else:
		init_default_screenshot()
		$Labels/Name.placeholder_text = "Empty Slot"
		$Labels/Date.visible = false
	
	if not save_mode:
		$Labels/Name.editable = false
		if error:
			self.disabled = true


func init_default_screenshot():
	var image = Image.new()
	image.create(16, 9, false, Image.FORMAT_RGB8)
	image.fill(image_background_color)
	$Screenshot.texture = ImageTexture.new()
	$Screenshot.texture.create_from_image(image, Image.FORMAT_RGB8)


func init_date(date:Dictionary):
	var formatted_date = {}
	for k in date.keys():
		formatted_date[k] = "%02d" % date[k]
	$Labels/Date.text = date_format.format(formatted_date)


var name_changed = false

func _on_name_entered(new_text):
	if save and name_changed:
		Agartha.Saver.rename(save, new_text)
	else:
		_on_pressed()
	if self.is_inside_tree():
		$Labels/Name.release_focus()


func _on_name_changed(_new_text):
	name_changed = true


func _on_name_edit_exited():
	if $Labels/Name.editable:
		_on_name_entered($Labels/Name.text)


func _on_pressed():
	if save_mode:
		Agartha.Saver.save(save_filename, $Labels/Name.text)
	else:
		Agartha.Saver.load(save)
		Agartha.get_tree().get_nodes_in_group("main_menu")[0].visible = false


func _on_mouse_entered():
	if not $Labels/Name.has_focus():
		self.grab_focus()


func _on_mouse_exited():
	self.release_focus()
