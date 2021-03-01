extends Node


func action(default_answer, parameters:Dictionary={}):
	Agartha.Timeline.block("ask")
	Agartha.emit_signal("ask", default_answer, parameters)


func return(return_value):
	Agartha.Timeline.unblock("ask", true)
	Agartha.emit_signal("ask_return", return_value)
	Agartha.step()
