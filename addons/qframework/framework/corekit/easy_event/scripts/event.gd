@abstract
class_name Event

var callables:Array[Callable] = []

func trigger(arg1 = null, arg2 = null, arg3 = null):
	for callable in callables:
		match callable.get_argument_count():
			0:
				callable.call()
			1:
				callable.call(arg1)
			2:
				callable.call(arg1,arg2)
			3:
				callable.call(arg1,arg2,arg3)
			_:
				push_error("Invalid argument count for callable: " + callable.get_method())
			

func register(method:Callable) -> UnRegister:
	callables.push_back(method)
	return UnRegister.new(self,method);
	
func or_event(other_event:Event)->OrEvent:
	return OrEvent.new(self,other_event)
	
func un_register(method:Callable):
	var index = callables.find(method);
	if index != -1:
		callables.remove_at(index);
