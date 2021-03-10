extends Resource
class_name Character

export var properties:Dictionary = {}

export var name:String
export var tag:String
export var color:Color = Color.white setget _set_color

export var show_parameters:Dictionary = {}
export var say_parameters:Dictionary = {}

export var name_format:String = "{name}"
export var name_format_bbcode:String = "[color=#{color}]{name}[/color]"


func _init(_name:String="", _tag:String="", _color=null):
	properties = {}
	show_parameters = {}
	say_parameters = {}
	if _name:
		name = _name
	if _tag:
		tag = _tag
	if _color:
		color = _color


func has(property):
	return property in self['properties']


func _to_string():
	return name_format.format({'name':name, 'color':color}).format(properties)


func bbcode():
	return name_format_bbcode.format({'name':name, 'color':color}).format(properties)


func _set_color(value):
	if value is String:
		color = Color(value)
	elif value is Color:
		color = Color(value.r, value.g. value.b, value.a)


## Setget magic and duplicate

func _get(property):
	if property in self['properties']:
		return self['properties'][property]
	return null

func _set(property, value):
	if not property_list:
		_init_property_list()
	if not property in property_list:
		self['properties'][property] = value
		return true

const property_list = {}
func _init_property_list():
	for p in get_property_list():
			property_list[p.name] = true

func duplicate(_deep:bool=true):
	var output = .duplicate(true)
	output.script = self.script
	for p in properties.keys():
		if properties[p] is Object and properties[p].has_method('duplicate'):
			output.properties[p] =  properties[p].duplicate(true)
	return output

