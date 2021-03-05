tool
extends Tree

var library:ShardLibrary = ShardLibrary.new()

var bundles:Array

signal open_shard(shard_id)

func _on_NewBundle_pressed():
	pass # Replace with function body.


func _on_NewShard_pressed():
	pass # Replace with function body.


func _on_open_library(library):
	self.library = library
	update_tree()

func update_tree():
	var tree = library.get_tree()
	
	self.clear()
	var root = self.create_item()
	self.set_hide_root(true)
	
	for b in tree.keys():
		place_item_in_tree(root, tree[b], b)

func place_item_in_tree(parent, branch, id):
	var tree_item = self.create_item(parent)
	var id_split = id.split("_")
	tree_item.set_text(0, id_split[id_split.size()-1])
	tree_item.set_meta("shard_id", id)
	for b in branch.keys():
		place_item_in_tree(tree_item, branch[b], b)

func _place_in_tree_i(shard_id, id_parts:Array, content, root:Array):
	var branch = root
	for id_p in id_parts.size():
		if id_p + 1 == id_parts.size():
			
			pass
		else:
			
			pass

func _get_branch(partial_id:String, branch:Array):
	#if not elements[element_id] in branch[0]:
	pass
		

func _place_in_tree(shard_id, content, branch:Array, elements:Array, element_id:int=0):
	if elements.size() <= element_id:
		return
	var tree_item
	if not elements[element_id] in branch[0]:
		tree_item = self.create_item(branch[1])
		tree_item.set_text(0, elements[element_id].capitalize())
		branch[0][elements[element_id]] = [{}, tree_item]
		
		if elements.size() == element_id + 1:
			tree_item.set_meta("shard_id", shard_id)
			tree_item.set_meta("shard", content)
		else:
			tree_item.set_selectable(0, false)
			var partial_id = (elements.slice(0, element_id) as PoolStringArray).join("_")
			tree_item.set_meta("shard_id", partial_id)

	elif elements.size() == element_id + 1:# If last element
		tree_item = branch[0][elements[element_id]][1]
		print(shard_id)
		tree_item.set_selectable(0, true)
			
		tree_item.set_meta("shard_id", shard_id)
		tree_item.set_meta("shard", content)
	else:
		_place_in_tree(shard_id, content, branch[0][elements[element_id]], elements, element_id + 1)
		

func _on_item_selected():
	print("Openning Shard id: %s" % self.get_selected().get_meta("shard_id"))
	self.emit_signal('open_shard', self.get_selected().get_meta("shard_id"))


func _on_update_shard_library():
	update_tree()
