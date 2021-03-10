extends Node
class_name Dialogue

var thread:Thread = null
var semaph:Semaphore

var execution_stack:Array = []

export var default_fragment:String = ""
export var autorun:bool = false

enum ExecMode {
	Regular,
	Forwarding,
	Exitting
}

var execution_mode:int = ExecMode.Regular

func _restore(state):
	if state.get('dialogue_name') == self.name:
		var restore_stack = _convert_execution_stack(state.get('dialogue_execution_stack'))
		_start_thread(restore_stack)
	else:
		_exit()


func _step():
	if execution_mode == ExecMode.Regular:
		if execution_stack:
			execution_stack[0].step_counter += 1
			self._store_step()
			semaph.post()
		


func _store_step(origin:bool=false):
	var state
	if origin:
		state = Agartha.Store.get_current_state_origin()
	else:
		state = Agartha.Store.get_current_state()
	state.set('dialogue_execution_stack', execution_stack.duplicate(true))
	state.set('dialogue_name', self.name)


func _start_thread(exec_stack):
	if thread:
		_exit()
		if thread.is_active():
			thread.wait_to_finish()
	
	execution_stack = exec_stack.duplicate(true)
	self.call_deferred('_store_step')
	thread = Thread.new()
	thread.start(self, '_thread_job', thread)

func _thread_job(thread):
	execution_mode = ExecMode.Regular
	while execution_stack and is_running():
		self.call(execution_stack[0].name)
	self.call_deferred('_end_thread', thread)



func ia():#Shorhand
	return is_active()
func is_active():
	return execution_mode == ExecMode.Regular

func _is_preactive(offset:int = 1):# The preactivation is used to only re-apply the safe functions non-data altering functions when restoring a prestep state (with potential data manipulation already applied)
	if execution_mode == ExecMode.Regular:
		return true
	elif execution_mode == ExecMode.Forwarding:
		if Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PreStep:
			if execution_stack[0].step_counter >= execution_stack[0].target_step:
				return true
	return false

func step():
	if Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PreStep:
		_prestep_mode_step()
	elif Agartha.Timeline.roll_mode == Agartha.Timeline.RollMode.PostStep:
		_poststep_mode_step()

func _poststep_mode_step():
	if execution_mode == ExecMode.Forwarding:
		if execution_stack[0].step_counter >= execution_stack[0].target_step:
			execution_mode = ExecMode.Regular
			execution_stack[0].erase('target_step')
		execution_stack[0].step_counter += 1
	elif is_active():
		semaph = Semaphore.new()
		semaph.wait()

func _prestep_mode_step():
	if execution_mode == ExecMode.Forwarding:
		if execution_stack[0].step_counter >= execution_stack[0].target_step:
			execution_mode = ExecMode.Regular
			execution_stack[0].erase('target_step')
		execution_stack[0].step_counter += 1
	if is_active():
		semaph = Semaphore.new()
		semaph.wait()






#######


func _ready():
	Agartha.connect("start_dialogue", self, '_start_dialogue')
	if autorun:
		if default_fragment:
			Agartha.start_dialogue(name, default_fragment)
			#self.call_deferred("_store_step", true)
		else:
			push_error("Autorun Dialogue is missing a default fragment.")


func start(fragment_name:String=""):
	if fragment_name:
		Agartha.emit_signal('start_dialogue', name, fragment_name)
	elif default_fragment:
		Agartha.emit_signal('start_dialogue', name, default_fragment)


func _start_dialogue(dialogue_name, fragment_name):
	if dialogue_name:
		if fragment_name:
			if self.has_method(fragment_name):
				var stack_entry = {'name':fragment_name, 'target_step':0}
				_start_thread([stack_entry])
			else:
				push_error("Invalid fragment name. '%s'" % fragment_name)
		else:
			push_error("Cannot start a Dialogue without a fragment name.")
	else:
		_exit()

func _end_thread(thread):
	if thread and thread.is_active():
		thread.wait_to_finish()
		self.thread = null


func _exit():
	execution_mode = ExecMode.Exitting
	semaph.post()


func _convert_execution_stack(stored_exec_stack):
	var converted_exec_stack = []
	
	for entry in stored_exec_stack:
		var converted_entry = entry.duplicate(true)
		converted_entry.target_step = entry.step_counter
		converted_entry.erase('step_counter')
		converted_exec_stack.append(converted_entry)
	
	return converted_exec_stack


########



func is_running():
	return execution_mode == ExecMode.Regular or execution_mode == ExecMode.Forwarding

func is_exitting():
	return execution_mode == ExecMode.Exitting


func fragment_start(name):
	if execution_stack and execution_stack[0].name == name and execution_stack[0].has('target_step'):
		execution_stack[0].step_counter = 0
		if execution_stack[0].target_step != 0:
			execution_mode = ExecMode.Forwarding
		else:
			execution_stack[0].erase('target_step')
	else:
		execution_stack.push_front({})
		execution_stack[0].name = name
		execution_stack[0].step_counter = 0

func fragment_end():
	execution_stack.pop_front()


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







################# Dialogue actions

func shard(shard_id:String, exact_id:bool=true, shard_library:Resource=null):
	if _is_preactive():
		var shard = Agartha.ShardLibrarian.get_shard(shard_id, exact_id)
		for l in shard:
			if _is_preactive():
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
			else:
				break


func show(tag:String, parameters:Dictionary={}):
	if _is_preactive():
		Agartha.Show_Hide.call_deferred("action_show", tag, parameters)


func hide(tag:String, parameters:Dictionary={}):
	if _is_preactive():
		Agartha.Show_Hide.call_deferred("action_hide", tag, parameters)


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
func _ask_callback(return_pointer:Array):
	return_pointer[0] = yield(Agartha, "ask_return")


func menu(entries:Array, parameters:Dictionary={}):
	if _is_preactive():
		var return_pointer = [null] # Using a array here with a null entry as a makeshift pointer
		_menu_callback(return_pointer)
		Agartha.Menu.call_deferred("action", entries, parameters)
		step()
		return return_pointer[0]
func _menu_callback(return_pointer:Array):
	return_pointer[0] = yield(Agartha, "menu_return")
