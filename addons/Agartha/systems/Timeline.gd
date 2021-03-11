extends Node

enum RollMode {
	PreStep,
	PostStep
}
export(int, "pre_step", "post_step") var roll_mode = RollMode.PreStep



func next_step():
	if any_blocker():
		call_for_blocked_step()
	else:
		Agartha.Store.store_current_state()
		call_for_storing()
		Agartha.Store.finish_step()
		#print("Stored State Stack: \n%s" % [Agartha.Store.state_stack])
		call_for_step()

func roll(amount:int):
	unblock_all()
	amount += Agartha.Store.current_state_id
	if amount >= 0 and amount < Agartha.Store.state_stack.size():
		Agartha.Store.restore_state(amount, roll_mode == RollMode.PostStep)
		print("Restoring state:\n%s" % [Agartha.Store.current_state])
		call_for_restoring()
		if roll_mode == RollMode.PostStep:
			print("Stepping after restore")
			call_for_step()

func call_for_step():
	get_tree().get_root().propagate_call("_step")

func call_for_blocked_step():
	get_tree().get_root().propagate_call("_blocked_step")

func call_for_storing():
	get_tree().get_root().propagate_call("_store", [Agartha.Store.get_current_state()])

func call_for_restoring():
	get_tree().get_root().propagate_call("_restore", [Agartha.Store.get_current_state()])


###### Skipping system

enum SkipPriority {
	SEEN, # Only skip seen text
	UNSEEN, # Skip un-important unseen text
	INPUT, # Skip even after requiring input (ask and menu), but only un-important
	IMPORTANT, # Skip important seen text, this level is given as an example
	KEY # Skip key text, this level is given as an example
}

var skip_priority:int = 0

signal skip_change(active, _priority)


func start_skipping(priority:int):
	self.emit_signal('skip_change', true, priority)
	skip_priority = priority
	$SkipDelay.wait_time = Agartha.Settings.get("agartha/dialogues/skip_delay")
	$SkipDelay.start()


func end_skipping():
	$SkipDelay.stop()
	self.emit_signal('skip_change', false, 0)


func skip_stop(stop_priority:int):
	if skip_priority < stop_priority:
		 end_skipping()


func _skip():
	Agartha.step()


###### Blocker system

const blockers:Dictionary = {}

func block(id, set:bool=false, amount:int=1):
	if amount < 1:
		push_warning("Cannot block '%s' a null or negative amount of time." % id)
		return 
	if set or not id in blockers:
		blockers[id] = amount
	else:
		blockers[id] += amount

func unblock(id, full:bool=false, amount:int=1):
	if amount < 1:
		push_warning("Cannot unblock '%s' a null or negative amount of time." % id)
		return
	if id in blockers:
		if full or blockers[id] <= amount:
			blockers.erase(id)
		else:
			blockers[id] += amount

func get_blocker(id):
	if id in blockers:
		return blockers[id]
	return 0

func unblock_all():
	blockers.clear()

func any_blocker():
	return not blockers.empty()
