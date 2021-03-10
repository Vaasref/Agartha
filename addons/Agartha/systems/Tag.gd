extends Node



func get(tag:String, strict:bool=false):
	var output = []
	tag = "# " + tag.trim_prefix("# ")
	if strict:
		output.get_tree().get_nodes_in_group(tag)
	else:
		for n in get_tree().get_nodes_in_group("tagged"):
			for g in n.get_groups():
				var t = g.replace("$", n.get_name())
				if g.begin_with(t):
					output += n
					break
	if output.size() == 1:
		output = output[0]
	return output

func get_tags(tag:String):
	var output = []
	tag = "# " + tag.trim_prefix("# ")
	output.append(tag)
	for n in get_tree().get_nodes_in_group("tagged"):
		for g in n.get_groups():
			var t = g.replace("$", n.get_name())
			if g.begin_with(t):
				output += g
	return output

func get_node_dict(tag:String):
	var output = {}
	tag = "# " + tag.trim_prefix("# ")
	for n in get_tree().get_nodes_in_group("tagged"):
		for g in n.get_groups():
			var t = g.replace("$", n.get_name())
			if g.begin_with(t):
				if t in output:
					output[t].append(n)
				else:
					output[t] = [n]
	return output
	
	
	
	
