extends Node


func action(character, text:String, parameters:Dictionary={}):
	var character_say_parameters = {}
	if character:
		if character is String and Agartha.store.has(character):
			character = Agartha.store.get(character)
		if character is Resource:#no elif here as it also test if the character loaded from the store is of the right type
			character_say_parameters = character.character_say_parameters
		else:
			character = null
	
	Agartha.History.log_text_line(character, text)
	
	parameters = Agartha.Settings.get_parameter_list("agartha/dialogues/actions_default_parameters/say", parameters, character_say_parameters)
	text = Agartha.MarkupParser.parse_text(text)
	
	Agartha.History.log_say(character, text, parameters)
	Agartha.emit_signal("say", character, text, parameters)
