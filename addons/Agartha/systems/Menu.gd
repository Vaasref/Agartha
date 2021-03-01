extends Node


func action(choices:Array, parameters:Dictionary={}):
	Agartha.Timeline.block("menu")
	Agartha.emit_signal("menu", choices, parameters)


func return(return_value):
	Agartha.Timeline.unblock("menu", true)
	Agartha.emit_signal("menu_return", return_value)
	Agartha.step()
