tool
extends Resource
class_name ShardLibrary


export var shards:Dictionary = {}


func get_shards(shard_id:String=""):
	var output = []
	var ids = get_children_ids(shard_id)
	
	for id in ids:
		output += shards[id]
	
	return output

func get_tree():
	return get_branch("")

func get_branch(shard_id_root):
	var output = []
	var shards = get_children_ids(shard_id_root)
	var branches = {}
	for i in shards.size():
		if shards[i] == shard_id_root:
			continue
		var branch_id = shards[i].trim_prefix(shard_id_root).split("_", false)[0]
		if shard_id_root:
			branch_id = "%s_%s" % [shard_id_root, branch_id]
		branches[branch_id] = true
	for b in branches.keys():
		branches[b] = get_branch(b)
	return branches

func get_children_ids(shard_id, trimmed:bool = false):
	var output = []
	for s in shards.keys():
		if s.begins_with(shard_id):
			if trimmed:
				output.append(s.trim_prefix(shard_id))
			else:
				output.append(s)
	return output

enum LineType {
	ERROR,
	SHARD_ID,#aka label
	SHORTCUT,
	COMMENT,
	SAY,
	SHOW
}
const LineType_names:Array = ["Error", "Shard_ID", "Shortcut", "Comment", "Say", "Show"]

func save_script(script):
	if not script is Array:
		return
	var shard_ids = []
	for i in script.size():
		if script[i] and script[i][0] == LineType.SHARD_ID:
			shard_ids.append(i)
	for i in shard_ids.size():
		if i + 1 == shard_ids.size():
			save_shard(script, shard_ids[i], script.size())
		else:
			save_shard(script, shard_ids[i], shard_ids[i+1])

func save_shard(script, start, end):
	if not script is Array or end >= script.size() and start > end:
		return
	var shard_id = script[start][1]
	var shard_script = []
	for i in range(start, end):
		shard_script.append(script[i].duplicate(true))
	self.shards[shard_id] = shard_script
