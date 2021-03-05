tool
extends EditorPlugin

const AgarthaIcon = preload("res://addons/Agartha/editor/icon.svg")

const ShardLibraryEditor = preload("res://addons/Agartha/editor/ShardLibraryEditor/ShardLibraryEditor.tscn")

var shard_library_editor_instance


func _enter_tree():
	shard_library_editor_instance = ShardLibraryEditor.instance()
	# Add the main panel to the editor's main viewport.
	get_editor_interface().get_editor_viewport().add_child(shard_library_editor_instance)
	# Hide the main panel. Very much required.
	make_visible(false)


func _exit_tree():
	if shard_library_editor_instance:
		shard_library_editor_instance.queue_free()


func has_main_screen():
	return true

func handles(object):
	if object is ShardLibrary:
		shard_library_editor_instance.open_library(object)
		return true
	return false

var hidden_list:Array

func make_visible(visible):
	if shard_library_editor_instance:
		#if visible:
			#hidden_list = []
			#for c in get_editor_interface().get_editor_viewport().get_children():
			#	if c.get('visible') is bool and c.visible:
					#hidden_list.append(c)
			#		c.visible = false
		#else:
			#for c in hidden_list:
			#	c.visible = true
			#hidden_list = []
		shard_library_editor_instance.visible = visible


func get_plugin_name():
	return "Agartha"


func get_plugin_icon():
	return AgarthaIcon
