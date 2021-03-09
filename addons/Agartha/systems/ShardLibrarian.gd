extends Node

var shard_libraries:Array = []


func init():
	var path = Agartha.Settings.get("agartha/paths/shard_libraries_folder")
	shard_libraries = get_libraries(path)
	if not shard_libraries:
		push_warning("No shard library got loaded, check the folder path.")


func get_libraries(path):
	var output = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue
			file_name = path + file_name
			if dir.current_is_dir():
				output += get_libraries(file_name)
			elif ResourceLoader.exists(file_name):
				var res = ResourceLoader.load(file_name) as ShardLibrary
				if res:
					output.append(res)
			file_name = dir.get_next()
	else:
		push_error("Selected directory for shard libraries doesn't exists.")
	return output


func get_shard(shard_id:String, exact:bool=true):
	var output = []
	for lib in shard_libraries:
		if exact:
			if shard_id in lib.shards:
				output = lib.shards[shard_id]
				break
		else:
			output += lib.get_shards(shard_id)
	return output
