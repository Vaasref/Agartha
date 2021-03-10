extends Node


func action(choices:Array, parameters:Dictionary={}):
	Agartha.Timeline.skip_stop(Agartha.Timeline.SkipPriority.INPUT)
	Agartha.Timeline.block("menu")
	parameters = Agartha.Settings.get_parameter_list("agartha/dialogues/actions_default_parameters/menu", parameters)
	Agartha.emit_signal("menu", choices, parameters)


func return(return_value):
	Agartha.Timeline.unblock("menu", true)
	Agartha.emit_signal("menu_return", return_value)
	Agartha.step()
