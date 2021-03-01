extends Node


func action(character, text:String, parameters:Dictionary={}):
	Agartha.emit_signal("say", character, text, parameters)
