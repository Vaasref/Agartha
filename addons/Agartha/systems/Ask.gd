extends Node


func action(default_answer, parameters:Dictionary={}):
	Agartha.Timeline.skip_stop(Agartha.Timeline.SkipPriority.INPUT)
	Agartha.Timeline.block("ask")
	parameters = Agartha.Settings.get_parameter_list("agartha/dialogues/actions_default_parameters/ask", parameters)
	Agartha.emit_signal("ask", default_answer, parameters)


func return(return_value):
	Agartha.Timeline.unblock("ask", true)
	Agartha.emit_signal("ask_return", return_value)
	Agartha.step()
