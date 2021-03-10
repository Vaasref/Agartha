extends Node

onready var Timeline:Node = get_node("Timeline")
onready var Store:Node = get_node("Store")
onready var Persistent:Node = get_node("Persistent")
onready var Settings:Node = get_node("Settings")
onready var Tag:Node = get_node("Tag")
onready var ShardParser:Node = get_node("ShardParser")
onready var MarkupParser:Node = get_node("MarkupParser")
onready var ShardLibrarian:Node = get_node("ShardLibrarian")
onready var History:Node = get_node("History")

onready var Say:Node = get_node("Say")
onready var Ask:Node = get_node("Ask")
onready var Menu:Node = get_node("Menu")

signal start_dialogue(dialogue_name, fragment_name)

signal say(character, text, parameters)

signal ask(default_answer, parameters)
signal ask_return(return_value)

signal menu(entries, parameters)
signal menu_return(return_value)


var store = null setget ,get_store


func _ready():
	Store.init()
	Persistent.init()
	Settings.init()
	MarkupParser.test()
	ShardLibrarian.init()
	History.init()

func step():
	Timeline.next_step()


func get_store():
	return Store.get_current_state()
