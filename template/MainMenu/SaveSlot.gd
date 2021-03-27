tool
extends Button
class_name SaveSlot

export var image_background_color:Color = Color.gray
var save:Resource = null
var path
var save_mode

const date_format:String = "{day}/{month}/{year} {hour}:{minute}"

signal saved()

func init(_path, _save, error, _save_mode):
	path = _path
	save_mode = _save_mode
	if _save and _save is StoreSave:
		save = _save
		if error and error == Agartha.Store.COMPATIBILITY_ERROR.DIFF_SCRIPT_COMP_CODE:
			init_default_screenshot()
			$Labels/Name.visible = false
			$Labels/Name.editable = false
			var file:File = File.new()
			init_date(OS.get_datetime_from_unix_time(file.get_modified_time(path)))
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
	if save:
		save.name = new_text
		var flag = 0
		if Agartha.Settings.get("agartha/saves/compress_savefiles"):
			flag = ResourceSaver.FLAG_COMPRESS
		var _o = ResourceSaver.save(path, save, flag)
		emit_signal("saved")
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
		Agartha.Store.save_store(path.get_file(), $Labels/Name.text)
		emit_signal("saved")
	else:
		Agartha.Store.load_store(save)
		#print("Loading save names '%s' at path %s" % [$Labels/Name.text, path])


func _on_mouse_entered():
	if not $Labels/Name.has_focus():
		self.grab_focus()


func _on_mouse_exited():
	self.release_focus()
