tool
extends Button
class_name SaveSlot

var save:Resource = null
var save_filename
var save_mode

const date_format:String = "{day}/{month}/{year} {hour}:{minute}"
const return_on_save:bool = false # not returning on save will make the main menu blink in order to take a screenshot 

func init(_save_filename, _save, _save_mode):
	save_filename = _save_filename
	save_mode = _save_mode
	save = _save
	var error = Agartha.Saver.check_save_compatibility(save, false)
	if save and save is StoreSave:
		if error and error == Agartha.Saver.COMPATIBILITY_ERROR.DIFF_SCRIPT_COMP_CODE:
			$Labels/Name.visible = false
			$Labels/Name.editable = false
			var file:File = File.new()
			init_date(OS.get_datetime_from_unix_time(file.get_modified_time(Agartha.Saver.get_save_path(save_filename))))
		else:
			$ScreenshotContainer/Screenshot.texture = save.get_screenshot_texture()
			$Labels/Name.text = save.name
			init_date(save.date)
			if Agartha.Persistent.get_value("_latest_save", "") == _save_filename:
				$Labels/Date.set("custom_colors/font_color", Color("#98eb7a"))
		if error:
			$ScreenshotContainer/Screenshot/Error.visible = true
		
	else:
		$Labels/Name.placeholder_text = "Empty Slot"
		$Labels/Date.visible = false
	
	if not save_mode:
		$Labels/Name.editable = false
		if error:
			self.disabled = true

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
		_pressed()
	if self.is_inside_tree():
		$Labels/Name.release_focus()

func _gui_input(event):
	if event.is_action_pressed("agartha_delete_save"):
		get_tree().get_nodes_in_group("save_confirm")[0].delete_confirm(save_filename)

func _on_name_changed(_new_text):
	name_changed = true


func _on_name_edit_exited():
	if $Labels/Name.editable:
		_on_name_entered($Labels/Name.text)


func _pressed():
	if save_mode:
		if save:
			get_tree().get_nodes_in_group("save_confirm")[0].overwrite_confirm(save_filename, $Labels/Name.text)
		else:
			var screenshot
			if return_on_save:
				Agartha.get_tree().get_nodes_in_group("main_menu")[0].visible = false
				yield(VisualServer, "frame_post_draw")
				screenshot = get_tree().get_root().get_texture().get_data()
			else: # das blinken menu (cf line 11)
				Agartha.get_tree().get_nodes_in_group("main_menu")[0].modulate = Color.transparent
				yield(VisualServer, "frame_post_draw")
				screenshot = get_tree().get_root().get_texture().get_data()
				Agartha.get_tree().get_nodes_in_group("main_menu")[0].modulate = Color.white
			screenshot.flip_y()
			Agartha.Saver.save(save_filename, $Labels/Name.text, screenshot)
	else:
		Agartha.Saver.load(save)
		Agartha.get_tree().get_nodes_in_group("main_menu")[0].visible = false


func _on_mouse_entered():
	if not $Labels/Name.has_focus():
		self.grab_focus()


func _on_mouse_exited():
	self.release_focus()
