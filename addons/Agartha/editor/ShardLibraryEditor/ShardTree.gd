tool
extends Tree

var library:ShardLibrary = ShardLibrary.new()

var bundles:Array

signal open_shard(shard_id)


func _on_open_library(library, _clear_editor):
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




func _on_item_selected():
	print("Openning Shard id: %s" % self.get_selected().get_meta("shard_id"))
	self.emit_signal('open_shard', self.get_selected().get_meta("shard_id"))


func _on_update_shard_library():
	update_tree()
