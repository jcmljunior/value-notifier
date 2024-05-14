class_name ValueNotifier extends Object

var _value: Variant:
	get: return _value;
	
	set(new_value):
		# Define temporariamente o valor atual.
		# Necessário para o retorno do estado.
		var old_value = _value;
		
		# Impede que valores nulos sejam inicializados.
		# Use o método dispose para destruir o objeto.
		if(typeof(new_value) == TYPE_NIL):
			return;
		
		# Define o novo valor.
		_value = new_value;
		
		# Notifica os observadores.
		notify(new_value, old_value);
		

var _listeners: Array;


func _set(property: StringName, value: Variant) -> bool:
	match property:
		"value", "_value":
			_value = value
			
			return true
	
	return false;

func _get(property: StringName) -> Variant:
	match property:
		"_value", "value":
			if("_value" in _value):
				return _value._value
			
			if("value" in _value):
				return _value.value
			
			return _value
			
		"_listeners", "listeners":
			return _listeners
	
	return null

func _init(initial_value: Variant) -> void:
	_value = initial_value

func subscribe(fnc: Callable, init: bool = false):
	_listeners.append(fnc)
	
	if init:
		fnc.bind(_value, _value).call()
		

	return {
		"subscribe": func():
			subscribe(fnc),
			
		"unsubscribe": func():
			unsubscribe(fnc),
	}

func unsubscribe(fnc: Callable):
	for i in range(_listeners.size()):
		if(not _listeners[i] == fnc):
			continue
		
		_listeners.remove_at(i)
		
		return true

func notify(new_value: Variant, old_value: Variant):
	for listener in _listeners:
		if not listener is Callable:
			continue
		
		listener.bind(new_value, old_value).call()

func has_listener(fnc: Callable) -> bool:
	var response := false
	
	for listener in _listeners:
		if not listener == fnc:
			continue
			
		response = true
		break
	
	return response

func dispose() -> void:
	for property in get_property_list():
		set(property.get("name"), null)
