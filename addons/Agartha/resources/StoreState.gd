extends Resource
class_name StoreState

export var properties:Dictionary = {}

func _init():
	properties = {}

func get(property):
	if property in self['properties']:
		return self['properties'][property]
	if property in get_property_list():
		return self[property]
	return null


func set(property, value):
	if property in get_property_list():
		self[property] = value
	elif value == null:
		var _o = self['properties'].erase(property)
	else:
		self['properties'][property] = value

func has(property):
	return property in self['properties']


func _to_string():
	var output = "(StoreState:%s)%s" % [self.get_instance_id(), properties]
	return output


func duplicate(_deep:bool=true):
	var output = .duplicate(true)
	output.script = self.script
	output.properties = self.properties.duplicate()
	for p in properties:
		if properties[p] is Object and properties[p].has_method('duplicate'):
			output.properties[p] =  properties[p].duplicate(true)
	return output
