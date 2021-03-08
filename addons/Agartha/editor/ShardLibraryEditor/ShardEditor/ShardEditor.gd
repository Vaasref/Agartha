tool
extends TextEdit

var ShardParser = preload("res://addons/Agartha/systems/ShardParser.gd")
var parser = ShardParser.new()

signal script_error(error)
signal update_shard_library()
signal update_shortcuts(shortcuts)
signal update_cursor(cursor_line, cursor_column)
signal save_new_library(new_library)


func _ready():
	update()


func update():
	update_colors()


func update_colors():
	self.clear_colors()
	self.add_color_region("@", "@", Color.goldenrod)
	self.add_color_region(":", ":", Color.mediumorchid)
	self.add_color_region("\"", "\"", Color.mediumseagreen)
	self.add_color_region("#", "", Color.indianred)
	self.add_keyword_color("show", Color.lightskyblue)


func _on_visibility_changed():
	var script = parser.parse_shard(self.text)
	update_text(script)


func _on_text_changed():
	var script = parser.parse_shard(self.text)
	update_text(script)


func update_text(script):
	var error = false
	self.emit_signal("script_error", "")#Reset the error display
	update_colors()
	var shard_started = false
	var shortcuts = {}
	var line = 1
	for l in script:
		if l:
			if not shard_started and l[0] != ShardParser.LineType.SHARD_ID:
				error = "Shard Script Error: shards must start with a Shard_ID. Line %d" % line
				self.emit_signal("script_error", error)
				push_error(error)
			match l[0]:
				ShardParser.LineType.ERROR:
					self.add_color_region(self.get_line(line-1), "", Color.crimson, true)
					if l.size() == 1:
						error = "Shard Script Error: syntax error line %d." % line
					else:
						error = "Shard Script Error: invalid '%s' syntax line %d." % [ShardParser.LineType_names[l[1]] ,line]
					self.emit_signal("script_error", error)
					push_error(error)
				ShardParser.LineType.SAY:
					if l[1]:
						self.add_keyword_color(l[1], Color.palevioletred)
				ShardParser.LineType.SHOW:
					if l.size() == 3:
						self.add_color_region(" "+l[1], " ", Color.cyan)
					else:
						self.add_color_region(" "+l[1], " ", Color.cyan, true)
				ShardParser.LineType.SHARD_ID:
					shard_started = true
				ShardParser.LineType.SHORTCUT:
					shortcuts[l[1]] = true
		line += 1
	self.emit_signal("update_shortcuts", shortcuts.keys())
	return error


var shard_library:ShardLibrary

func open_shard_library(library):
	self.text = ""
	shard_library = library


func open_shard(shard_id):
	if shard_library:
		var shard = shard_library.get_shards(shard_id)
		if shard:
			if shard is String:
				self.text = shard
			else:
				self.text = parser.compose_shard(shard)
				update_text(shard)
		else:
			self.text = ":%s:\n" % shard_id


func update_shard_library(script):
	if shard_library:
		shard_library.save_script(script)


func _on_save_button_pressed():
	var script = parser.parse_shard(self.text)
	var error = update_text(script)
	if not error:
		if shard_library:
			update_shard_library(script)
			self.emit_signal('update_shard_library')
		else:
			var new_library = ShardLibrary.new()
			new_library.save_script(script)
			self.emit_signal('save_new_library', new_library)


func can_drop_data(position, data):
	if data is Dictionary and data.type == "files":
		return true
	return false


func drop_data(position, data):
	var line = self.cursor_get_line()
	
	self.cursor_set_line(self.cursor_get_line() + 1)
	self.cursor_set_column(0)

	for file in data.files:
		line += 1
		self.insert_text_at_cursor("\t@%s@\n" % file)
	
	self.cursor_set_line(self.cursor_get_line() - 1)
	self.cursor_set_column(1000)#If you have a file path longer than that you probably need a(an other) psychiatrist
	self.grab_focus()


func _on_cursor_changed():
	self.emit_signal('update_cursor', self.cursor_get_line(), self.cursor_get_column())


func _on_insert_shard_script(script_text):
	self.text = script_text
	var script = parser.parse_shard(self.text)
	update_text(script)
