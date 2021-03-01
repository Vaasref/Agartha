extends Node

onready var Timeline:Node = get_node("Timeline")
onready var Store:Node = get_node("Store")
onready var Persistent:Node = get_node("Persistent")

onready var Say:Node = get_node("Say")
onready var Ask:Node = get_node("Ask")
onready var Menu:Node = get_node("Menu")

signal start_dialogue(dialogue_name, fragment_name)

signal say(character, text, parameters)

signal ask(default_answer, parameters)
signal ask_return(return_value)

signal menu(entries, parameters)
signal menu_return(return_value)


func _ready():
	Store.init()
	Persistent.init()

func step():
	Timeline.next_step()
