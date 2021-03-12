extends Node


func action_show(tag:String, parameters:Dictionary={}):
	var split_tag = tag.split(" ")
	var character_show_parameters = _get_character_parameters(split_tag[0])
	
	parameters = Agartha.Settings.get_parameter_list("agartha/dialogues/actions_default_parameters/show", parameters, character_show_parameters)
	
	show(tag, parameters)
	Agartha.emit_signal("show", tag, parameters)

func action_hide(tag:String, parameters:Dictionary={}):
	var split_tag = tag.split(" ")
	var character_show_parameters = _get_character_parameters(split_tag[0])
	
	parameters = Agartha.Settings.get_parameter_list("agartha/dialogues/actions_default_parameters/hide", parameters, character_show_parameters)
	
	hide(tag, parameters)
	Agartha.emit_signal("hide", tag, parameters)

func _get_character_parameters(first_tag_element:String):
	var output = {}
	if Agartha.store.has(first_tag_element):
		var character = Agartha.store.get(first_tag_element)
		if character is Resource:
			output = character.character_say_parameters
	return output


## Shown tag management

var shown = {} setget _set_shown, _get_shown

func _set_shown(value):
	Agartha.store.set("_show", value)

func _get_shown():
	if Agartha.store.has("_show"):
		Agartha.store.get("_show")
	else:
		return {}
	

func show(tag:String, parameters:Dictionary):
	tag = "# " + tag.trim_prefix("# ")
	var radical = tag.split(" ", false, 2)[1]
	var dict_to_show = Agartha.Tag.get_node_dict(tag)
	var nodes_to_show = []
	var new_shown = {}
	for t in dict_to_show.keys():
		nodes_to_show += dict_to_show[t]
		new_shown[t] = true
	shown[radical] = new_shown
	
	var family = Agartha.Tag.get(radical)
	for n in family:
		if n :
			if n in nodes_to_show:
				if not n.get("visible"):
					if n.has_method("_show"):
						n.call("_show", tag, parameters)
					elif n.has_method("show"):
						n.call("show")
			else:
				if n.has_method("_hide"):
					n.call("_hide", tag, parameters)
				elif n.has_method("hide"):
					n.call("hide")

	
func hide(tag:String, parameters:Dictionary):
	tag = "# " + tag.trim_prefix("# ")
	var radical = tag.split(" ", false, 2)[1]
	var dict_to_hide = Agartha.Tag.get_node_dict(tag)
	var nodes_to_hide = []
	var new_shown
	if radical in shown:
		new_shown = shown[radical].duplicate()
	else:
		new_shown = {}
	for t in dict_to_hide.keys():
		new_shown.erase(t)
		nodes_to_hide += dict_to_hide[t]
	if new_shown:
		shown[radical] = new_shown
	else:
		shown.erase(radical)
	
	var family = Agartha.Tag.get(radical)
	if family is Array:
		for n in family:
			if n:
				if n in nodes_to_hide:
					if n.has_method("_hide"):
						n.call("_hide", tag, parameters)
					elif n.has_method("hide"):
						n.call("hide")
	else:
		if family in nodes_to_hide:
			if family.has_method("_hide"):
				family.call("_hide", tag, parameters)
			elif family.has_method("hide"):
				family.call("hide")
	
	
	
	
	
	
