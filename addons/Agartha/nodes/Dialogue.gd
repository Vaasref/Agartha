extends Node
class_name Dialogue

export var default_fragment:String = ""
export var autorun:bool = false

var thread:Thread = null
var semaph:Semaphore

var execution_stack:Array = []

enum ExecMode {
	Starting,
	Regular,
	Forwarding,
	Exitting
}
var execution_mode:int = ExecMode.Regular


func _ready():
	Agartha.connect("start_dialogue", self, '_start_dialogue')
	if autorun:
		self.call_deferred('start')


func _start_dialogue(dialogue_name, fragment_name):
	if dialogue_name == self.name:
		start(fragment_name)


func start(fragment_name:String=""):
	var exec_stack
	if fragment_name:
		exec_stack = [{'fragment_name': fragment_name}]
	elif default_fragment:
		exec_stack = [{'fragment_name': default_fragment}]
	else:
		push_error("Trying to start the dialogue '%s' without fragment name." % [self.name])
		return
	_start_thread(exec_stack)


func _store(state):
	if is_active():
		state.set('dialogue_execution_stack', execution_stack.duplicate(true))
		state.set('dialogue_name', self.name)

func _restore(state):
	if state.get('dialogue_name') == self.name:
		var exec_stack = state.get('dialogue_execution_stack')
		if exec_stack: # just to be sure it is there
			_start_thread(exec_stack)
			semaph = Semaphore.new()
	else:
		exit_dialogue()

########

func _step():
	if semaph:
		semaph.post()

func step():
	if is_running():
		if execution_mode == ExecMode.Forwarding:
			if execution_stack[0].step_counter >= execution_stack[0].target_step:
				execution_mode = ExecMode.Regular
				var _o = execution_stack[0].erase('target_step')
		if execution_mode == ExecMode.Regular:
			_store(Agartha.Store.get_current_state())
			_wait_semaphore()
			execution_stack[0]['step_counter'] += 1
		else:
			execution_stack[0]['step_counter'] += 1

func _wait_semaphore():#This function allow to pre-post the semaphore
	if not semaph:
		semaph = Semaphore.new()
	semaph.wait()
	semaph = null

func _start_thread(exec_stack):
	if thread:
		exit_dialogue()
		if thread.is_active():
			thread.wait_to_finish()

	execution_stack = exec_stack.duplicate(true)
	thread = Thread.new()
	thread.start(self, '_execution_loop', thread)


func _execution_loop(thread):
	execution_mode = ExecMode.Starting
	while execution_stack and not is_exitting():
		if execution_stack[0].has('step_counter'):
			_recall_fragment()
		else:
			var fragment_name = execution_stack.pop_front()['fragment_name']
			execution_mode = ExecMode.Regular
			call_fragment(fragment_name)
	self.call_deferred('_end_thread', thread)


func _end_thread(thread:Thread):
	if thread and thread.is_active():
		thread.wait_to_finish()
		self.thread = null
		_clear_from_store()

func _clear_from_store():
	var state = Agartha.Store.get_current_state()
	if state.get('dialogue_name') == self.name:
		state.set('dialogue_execution_stack', null)
		state.set('dialogue_name', null)

func _recall_fragment():
	if self.has_method(execution_stack[0]['fragment_name']):
		execution_mode = ExecMode.Forwarding
		execution_stack[0]['target_step'] = execution_stack[0]['step_counter']
		execution_stack[0]['step_counter'] = 0
		self.call(execution_stack[0]['fragment_name'])
		execution_stack.pop_front()
	else:
		push_error("Invalid fragement name '%s' in dialogue '%s'" % [execution_stack[0]['fragment_name'], self.name])


func _is_preactive():
	if execution_mode == ExecMode.Regular:
		return true
	elif execution_mode == ExecMode.Forwarding:
		if Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PreStep:
			if execution_stack[0].step_counter >= execution_stack[0].target_step:
				return true
	return false




###########

func ia():#Shorhand
	return is_active()
func is_active():
	return execution_mode == ExecMode.Regular

func is_running():
	return execution_mode == ExecMode.Regular or execution_mode == ExecMode.Forwarding

func is_exitting():
	return execution_mode == ExecMode.Exitting


### User-side execution actions

func exit_dialogue():
	execution_mode = ExecMode.Exitting
	if semaph:
		semaph.post()


func call_fragment(fragment_name:String):
	if is_active():
		if self.has_method(fragment_name):
			var entry = {'fragment_name':fragment_name, 'step_counter':0}
			if execution_stack:
				execution_stack[0].step_counter += 1
			execution_stack.push_front(entry)
			self.call(fragment_name)
			execution_stack.pop_front()
			if execution_stack:
				execution_stack[0].step_counter -= 1
		else:
			push_error("Invalid fragement name '%s' in dialogue '%s'" % [fragment_name, self.name])
	else:
		step()


func start_dialogue(dialogue_name, fragment_name, scene_id:String=""):
	if is_running():
		if scene_id:
			var ok = Agartha.StageManager.change_scene(scene_id)
			if ok:
				Agartha.start_dialogue(dialogue_name, fragment_name)
		else:
			Agartha.start_dialogue(dialogue_name, fragment_name)


func cond(condition):#Shorhand
	return condition(condition)
func condition(condition):
	match execution_mode:
		ExecMode.Regular:
			if not execution_stack[0].has('condition_stack'):
				execution_stack[0].condition_stack = []
			if condition:
				condition = true
			else:
				condition = false
			execution_stack[0].condition_stack.push_front(condition)
		ExecMode.Forwarding:
			if execution_stack[0].has('condition_stack'):
				condition = execution_stack[0].condition_stack.pop_back()
			else:
				push_error("Condition stack misalignment.")
	return condition

func shard(shard_id:String, exact_id:bool=true, shard_library:Resource=null):
	if is_running():
		var shard = Agartha.ShardLibrarian.get_shard(shard_id, exact_id)
		for l in shard:
			if is_running():
				if l:
					match l[0]:
						Agartha.ShardParser.LineType.SAY:
							say(l[1], l[2])
							step()
						Agartha.ShardParser.LineType.SHOW:
							show(l[1])
						Agartha.ShardParser.LineType.HIDE:
							hide(l[1])
						Agartha.ShardParser.LineType.PLAY:
							print("play %s" % l[1])
						Agartha.ShardParser.LineType.HALT:
							halt(l[1])
			else:
				break


################# Dialogue actions


func show(tag:String, parameters:Dictionary={}):
	if _is_preactive():
		Agartha.Show_Hide.call_deferred("action_show", tag, parameters)


func hide(tag:String, parameters:Dictionary={}):
	if _is_preactive():
		Agartha.Show_Hide.call_deferred("action_hide", tag, parameters)


func halt(priority:int):
	if _is_preactive():
		Agartha.Timeline.call_deferred("skip_stop", priority)


func say(character, text:String, parameters:Dictionary={}):
	if _is_preactive():
		Agartha.Say.call_deferred("action",character, text, parameters)


func ask(default_answer:String="", parameters:Dictionary={}):
	if _is_preactive():
		var return_pointer = [null] # Using a array here with a null entry as a makeshift pointer
		_ask_callback(return_pointer)
		Agartha.Ask.call_deferred("action", default_answer, parameters)
		step()
		return return_pointer[0]
	step()
func _ask_callback(return_pointer:Array):
	return_pointer[0] = yield(Agartha, "ask_return")


func menu(entries:Array, parameters:Dictionary={}):
	if _is_preactive():
		var return_pointer = [null] # Using a array here with a null entry as a makeshift pointer
		_menu_callback(return_pointer)
		Agartha.Menu.call_deferred("action", entries, parameters)
		step()
		return return_pointer[0]
	step()
func _menu_callback(return_pointer:Array):
	return_pointer[0] = yield(Agartha, "menu_return")



#
#func _restore(state):
#	if state.get('dialogue_name') == self.name:
#		var restore_stack = _convert_execution_stack(state.get('dialogue_execution_stack'))
#		_start_thread(restore_stack)
#	else:
#		_exit()
#
#
#func _step():
#	if execution_mode == ExecMode.Regular:
#		if execution_stack:
#			execution_stack[0].step_counter += 1
#			self._store_step()
#			semaph.post()
#
#
#
#func _store_step(origin:bool=false):
#	var state
#	if origin:
#		state = Agartha.Store.get_current_state_origin()
#	else:
#		state = Agartha.Store.get_current_state()
#	state.set('dialogue_execution_stack', execution_stack.duplicate(true))
#	state.set('dialogue_name', self.name)
#
#
#func _start_thread(exec_stack):
#	if thread:
#		_exit()
#		if thread.is_active():
#			thread.wait_to_finish()
#
#	execution_stack = exec_stack.duplicate(true)
#	self.call_deferred('_store_step')
#	thread = Thread.new()
#	thread.start(self, '_thread_job', thread)
#
#func _thread_job(thread):
#	execution_mode = ExecMode.Regular
#	while execution_stack and is_running():
#		self.call(execution_stack[0].name)
#	self.call_deferred('_end_thread', thread)
#
#func _is_preactive(offset:int = 1):# The preactivation is used to only re-apply the safe functions non-data altering functions when restoring a prestep state (with potential data manipulation already applied)
#	if execution_mode == ExecMode.Regular:
#		return true
#	elif execution_mode == ExecMode.Forwarding:
#		if Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PreStep:
#			if execution_stack[0].step_counter >= execution_stack[0].target_step:
#				return true
#	return false
#
#func step():
#	if Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PreStep:
#		_prestep_mode_step()
#	elif Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PostStep:
#		_poststep_mode_step()
#
#func _poststep_mode_step():
#	if execution_mode == ExecMode.Forwarding:
#		if execution_stack[0].step_counter >= execution_stack[0].target_step:
#			execution_mode = ExecMode.Regular
#			execution_stack[0].erase('target_step')
#		execution_stack[0].step_counter += 1
#	elif is_active():
#		semaph = Semaphore.new()
#		semaph.wait()
#
#func _prestep_mode_step():
#	if execution_mode == ExecMode.Forwarding:
#		if execution_stack[0].step_counter >= execution_stack[0].target_step:
#			execution_mode = ExecMode.Regular
#			execution_stack[0].erase('target_step')
#		execution_stack[0].step_counter += 1
#	if is_active():
#		semaph = Semaphore.new()
#		semaph.wait()
#
#
#
#
#
#
########
#
#
#func _ready():
#	Agartha.connect("start_dialogue", self, '_start_dialogue')
#	if autorun:
#		if default_fragment:
#			Agartha.start_dialogue(name, default_fragment)
#			#self.call_deferred("_store_step", true)
#		else:
#			push_error("Autorun Dialogue is missing a default fragment.")
#
#
#func start(fragment_name:String=""):
#	if fragment_name:
#		Agartha.emit_signal('start_dialogue', name, fragment_name)
#	elif default_fragment:
#		Agartha.emit_signal('start_dialogue', name, default_fragment)
#
#
#func _start_dialogue(dialogue_name, fragment_name):
#	if dialogue_name and dialogue_name == self.name:
#		if fragment_name:
#			print("Has method %s" % self.has_method(fragment_name))
#			if self.has_method(fragment_name):
#				var stack_entry = {'name':fragment_name, 'target_step':0}
#				_start_thread([stack_entry])
#			else:
#				push_error("Invalid fragment name '%s' in %s." % [fragment_name, dialogue_name])
#		else:
#			push_error("Cannot start a Dialogue without a fragment name.")
#	else:
#		_exit()
#
#func _end_thread(thread):
#	if thread and thread.is_active():
#		thread.wait_to_finish()
#		self.thread = null
#
#
#func _exit():
#	execution_mode = ExecMode.Exitting
#	if semaph:
#		semaph.post()
#
#
#func _convert_execution_stack(stored_exec_stack):
#	var converted_exec_stack = []
#	print("stored_exec_stack %s" % [stored_exec_stack])
#	for entry in stored_exec_stack:
#
#		var converted_entry = entry.duplicate(true)
#		if entry.has('step_counter'):
#			converted_entry.target_step = entry.step_counter
#			converted_entry.erase('step_counter')
#		converted_exec_stack.append(converted_entry)
#		print(converted_entry)
#
#	return converted_exec_stack
