extends Resource
class_name StoreState

export var properties:Dictionary = {}



func _init():
	properties = {}


func has(property):
	return property in self['properties']


func _to_string():
	var output = "(StoreState:%s)%s" % [self.get_instance_id(), properties]
	return output


## Setget magic and duplicate

func _get(property):
	if property in self['properties']:
		return self['properties'][property]
	return null

func _set(property, value):
	if not property_list:
		_init_property_list()
	if not property in property_list:
		if value:
			self['properties'][property] = value
		else:
			var _o = self['properties'].erase(property)
		return true

const property_list = {}
func _init_property_list():
	for p in get_property_list():
			property_list[p.name] = true

func duplicate(_deep:bool=true):
	var output = .duplicate(true)
	output.script = self.script
	output.properties = self.properties.duplicate()
	for p in properties.keys():
		if properties[p] is Object and properties[p].has_method('duplicate'):
			output.properties[p] =  properties[p].duplicate(true)
	return output
