extends Node

var seen_lines:Dictionary = {}
var line_log:Array

func init():
	if Agartha.Persistent.has_value("_history_seen_lines"):
		seen_lines = Agartha.Persistent.get_value("_history_seen_lines")


func log_say(character, text, parameters):
	var character_tag = ""
	if character is Character:
		character_tag = character.tag
	line_log.append([character_tag, text, parameters]) 


func log_text_line(character, text_line:String):
	var character_tag = ""
	if character is Character:
		character_tag = character.tag
	var entry = "%s-%s" % [character_tag, text_line.sha256_text()]
	if not seen_lines.has(entry):
		seen_lines[entry] = true
		Agartha.Timeline.skip_stop(Agartha.Timeline.SkipPriority.UNSEEN)
	update_persistent()


func clear_persistent_history():
	seen_lines = {}
	update_persistent()


func update_persistent():
	Agartha.Persistent.set_value("_history_seen_lines", seen_lines.duplicate(true))



