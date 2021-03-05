tool
extends Node

const sample = "#Comment\n" \
+"shard_0:\n"\
+"	\"Text line without sayer.\"\n"\
+"	a \"Text line with sayer.\"\n"\
+"$:   #Sequential id (will use last id and increment it)\n"\
+"	\"Second shard\"\n"\
+"	show stuff\n"\
+"	@shortcut-to-open-script-or-shard\n"\
+"	\"Not a \\#comment\"\n"\
+"	\"Not a \\@shortcut\"\n"\
+"	Bad line formatting\n"\
+"	Also bad formatting\"\n"\
+"	\"Still bad formatting\n"\

func _ready():
	#var text = sample
	#print("Shard Script: \n%s\n\n" % sample)
	#var script = [null, text]
	#split_script(script)
	#print(script)

	#text = remove_comments(text)
	#text = remove_shortcuts(text)
	#print("Shard Script without comments: \"\n%s\n\"\n" % text)
	#var script = [null, text]
	#split_script(script)
	pass


enum LineType {
	ERROR,
	SHARD_ID,#aka label
	SHORTCUT,
	COMMENT,
	SAY,
	SHOW
}
const LineType_names:Array = ["Error", "Shard_ID", "Shortcut", "Comment", "Say", "Show"]


func parse_shard(shard_script):
	var lines = shard_script.split("\n", true)
	var script = []
	
	for i in lines.size():
		script.append([i+1, lines[i], parse_line(lines[i])])
	
	var last_shard_id = ""
	for l in script:
		if l[2] and l[2][0] == LineType.SHARD_ID:
			#print("Shard_ID '%s'" % l[2][2])
			if l[2][2] == "$":
				if last_shard_id:
					#print("Generating sequential shard from '%s'" % last_shard_id)
					l[2][2] = generate_sequential_id(last_shard_id)
			else:
				last_shard_id = l[2][2]
	
	return script

func generate_sequential_id(previous_id:String):
	var re = RegEx.new()
	re.compile("^(.*)((?<![0-9])[0-9]+)$")
	var result = re.search(previous_id)
	if result:
		var output = result.get_string(1) + String(int(result.get_string(2)) + 1)
		return output
	return "%s_0" % previous_id

func parse_line(line:String):
	var re = RegEx.new()
	var result
	var comment = false
	
	re.compile("([^#\\s]?)([ \\t]*(?<!\\\\)#[^\\n]*)")
	result = re.search(line)
	if result:
		if not result.get_string(1):
			return [LineType.COMMENT, result.get_string(2)]
		line = line.substr(0, result.get_start(2))
		comment = result.get_string(2)
	
	var trimmed_line = line.strip_edges()
	
	if trimmed_line.begins_with("@"):
		re.compile("[\\s]*@([^@\\s]+)@[\\s]*")
		result = re.search(line)
		if result:
			return [LineType.SHORTCUT, result.get_string(0), result.get_string(1), comment]
		else:
			return [LineType.ERROR, LineType.SHORTCUT]#Returns and error with shortcut flavor
	elif trimmed_line.ends_with(":"):
		re.compile("^:([\\w]+|\\$):[\\s]*")
		result = re.search(line)
		if result:
			return [LineType.SHARD_ID, result.get_string(0), result.get_string(1), comment]
		else:
			return [LineType.ERROR, LineType.SHARD_ID]#Returns and error with shard_id flavor
	elif trimmed_line.begins_with("show "):
		re.compile("[\\s]*show (.*)")
		result = re.search(line)
		if result:
			return [LineType.SHOW, result.get_string(0), result.get_string(1).strip_edges(), comment]
		else:
			return [LineType.ERROR, LineType.SHOW]#Returns and error with show flavor
	elif "\"" in trimmed_line:
		re.compile("[\\s]*([\\w]*)[\\s]*\"(.*)\"")
		result = re.search(line)
		if result:
			return [LineType.SAY, result.get_string(1), result.get_string(2), comment]
		else:
			return [LineType.ERROR, LineType.SAY]#Returns and error with say flavor
	
	if not trimmed_line:
		return []
	return [LineType.ERROR]#Return a general error




func compose_shard(script):
	var output = ""
	var comment
	var sayer
	for l in script:
		if l[2]:
			if l[2][0] != LineType.COMMENT and l[2][3]:
				comment = "  %s" % l[2][3]
			else:
				comment = ""
			
			match l[2][0]:
				LineType.SHARD_ID:
					output += ":%s:%s" % [l[2][2], comment]
				LineType.SHORTCUT:
					output += "\t@%s@%s" % [l[2][2], comment]
				LineType.COMMENT:
					output += "\t%s" % l[2][1]
				LineType.SAY:
					if l[2][1]:
						sayer = "%s " % l[2][1]
					else:
						sayer = ""
					output += "\t%s\"%s\"%s" % [sayer, l[2][2], comment]
				LineType.SHOW:
					output += "\tshow %s%s" % [l[2][2], comment]
		output += "\n"
	
	return output
