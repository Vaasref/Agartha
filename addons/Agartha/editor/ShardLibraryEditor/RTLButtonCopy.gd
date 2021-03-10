tool
extends RichTextLabel

var base_text

func _ready():
	base_text = self.bbcode_text
	get_parent().connect("draw", self, "update_state")
	pass

func get_theme_r(control):
	var theme = null
	while control != null and "theme" in control:
		theme = control.theme
		if theme != null: break
		control = control.get_parent()
	return theme

func update_state():
	var th = get_theme_r(self)
	if th:
		match get_parent().get_draw_mode():
			0:
				self.bbcode_text = "[color=#%s]%s[/color]" % [th.get_color("font_color", "Button").to_html(false), base_text]
			1:
				self.bbcode_text = "[color=#%s]%s[/color]" % [th.get_color("font_color_pressed", "Button").to_html(false), base_text]
			2:
				self.bbcode_text = "[color=#%s]%s[/color]" % [th.get_color("font_color_hover", "Button").to_html(false), base_text]
			_:
				self.bbcode_text = "[color=#%s]%s[/color]" % [th.get_color("font_color_disabled", "Button").to_html(false), base_text]
	pass
