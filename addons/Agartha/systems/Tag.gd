extends Node



func get(tag:String, strict:bool=false):
	var output = []
	tag = "# " + tag.trim_prefix("# ").to_lower()
	if strict:
		output.get_tree().get_nodes_in_group(tag)
	else:
		for n in get_tree().get_nodes_in_group("tagged"):
			for g in n.get_groups():
				var t = g.replace("$", n.get_name()).to_lower()
				if t.begins_with(tag):
					output.append(n)
					break
	if output.size() == 1:
		output = output[0]
	return output

func get_tags(tag:String):
	var output = []
	tag = "# " + tag.trim_prefix("# ").to_lower()
	output.append(tag)
	for n in get_tree().get_nodes_in_group("tagged"):
		for g in n.get_groups():
			var t = g.replace("$", n.get_name()).to_lower()
			if t.begins_with(tag):
				output += t
	return output

func get_node_dict(tag:String):
	var output = {}
	tag = "# " + tag.trim_prefix("# ").to_lower()
	for n in get_tree().get_nodes_in_group("tagged"):
		for g in n.get_groups():
			var t = g.replace("$", n.get_name()).to_lower()
			if t.begins_with(tag):
				if t in output:
					output[t].append(n)
				else:
					output[t] = [n]
	return output
	
	
	
	
