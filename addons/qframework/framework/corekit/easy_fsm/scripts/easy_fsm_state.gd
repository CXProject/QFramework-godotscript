@abstract
class_name EasyFSMState

var id:int;
var enter_callback:Callable;
var process_callback:Callable;
var physics_process_callback:Callable;
var exit_callback:Callable;
var fsm:EasyFSM
var target:Object

func _init(_state_id:int,_target:Object,_fsm:EasyFSM) -> void:
	id = _state_id
	fsm = _fsm
	target = _target

@abstract
func enter()
		
@abstract
func process(_delta:float)

@abstract
func physics_process(_delta:float)

@abstract
func exit()

func clear():
	fsm = null
	target = null
