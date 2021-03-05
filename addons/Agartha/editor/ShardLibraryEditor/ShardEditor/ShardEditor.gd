tool
extends TextEdit

var ShardParser = preload("res://addons/Agartha/systems/ShardParser.gd")
var parser = ShardParser.new()


signal script_error(error)
signal update_shard_library()

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
	change_pending = true
	var script = parser.parse_shard(self.text)
	update_text(script)
	
	
func update_text(script):
	var error = false
	self.emit_signal("script_error", "")#Reset the error display
	update_colors()
	var shard_started = false
	for l in script:
		if l[2]:
			if not shard_started and l[2][0] != ShardParser.LineType.SHARD_ID:
				error = "Shard Script Error: shards must start with a Shard_ID. Line %d" % l[0]
				self.emit_signal("script_error", error)
				push_error(error)
			match l[2][0]:
				ShardParser.LineType.ERROR:
					self.add_color_region(l[1], "", Color.crimson, true)
					if l[2].size() == 1:
						error = "Shard Script Error: syntax error line %d." % l[0]
					else:
						error = "Shard Script Error: invalid '%s' syntax line %d." % [ShardParser.LineType_names[l[2][1]] ,l[0]]
					self.emit_signal("script_error", error)
					push_error(error)
				ShardParser.LineType.SAY:
					if l[2][1]:
						self.add_keyword_color(l[2][1], Color.palevioletred)
				ShardParser.LineType.SHOW:
					if l[2][3]:
						self.add_color_region(" "+l[2][2], " ", Color.cyan)
					else:
						self.add_color_region(" "+l[2][2], " ", Color.cyan, true)
				ShardParser.LineType.SHARD_ID:
					shard_started = true
	return error

var shard_library:ShardLibrary

func open_shard_library(library):
	self.text = ""
	shard_library = library

var change_pending:bool = false

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
		change_pending = false

func update_shard_library(script):
	if shard_library:
		shard_library.save_script(script)


func _on_save_button_pressed():
	var script = parser.parse_shard(self.text)
	var error = update_text(script)
	if shard_library and not error:
		update_shard_library(script)
		self.emit_signal('update_shard_library')
	pass # Replace with function body.
