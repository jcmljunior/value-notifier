class_name ValueNotifier extends Object


var _value: Variant:
	set(new_value):
		var old_value = _value

		# Impede que o novo valor seja computado caso o tipo nao seja correspondente ao valor anterior.
		if not typeof(new_value) == typeof(old_value):
			# Permite a inicialização do valor.
			if typeof(old_value) == TYPE_NIL:
				_value = new_value
				return


			# TODO: Substituir a função printerr por assert.
			printerr("Oppss, o valor precisa ser: %s mas retornou: %s" % [ typeof(old_value), typeof(new_value) ])
			return


		_value = new_value


		# Notifica os observadores.
		handle_notifier_listeners(_listeners, new_value, old_value)

	get: return _value


var _listeners: Array


func _init(initial_value: Variant) -> void:
	_value = initial_value


func _set(property: StringName, value: Variant) -> bool:
	if not property.begins_with("_"):
		match property:
			"value":
				set("_value", value)
				return true


	return false


func _get(property: StringName) -> Variant:
	if property == "value":
		return _value

	elif property == "listeners":
		return _listeners

	elif property in self:
		return get(property)


	return null


func add_listener(fnc: Callable) -> void:
	_listeners.append(fnc)


func remove_listener(fnc: Callable) -> bool:
	var has_removed := false

	for i in range(_listeners.size() -1, -1, -1):
		if not _listeners[i] == fnc:
			continue


		_listeners.remove_at(i)
		has_removed = true

		break


	return has_removed


func handle_notifier_listeners(listeners: Array, new_value: Variant, old_value: Variant) -> void:
	if not _listeners.size():
		return

	if not new_value:
		return


	_notifier_listeners(listeners, new_value, old_value)


func _notifier_listeners(listeners: Array, new_value: Variant, old_value: Variant) -> void:
	for listener in listeners:
		listener.bind(new_value, old_value).call()


func dispose() -> void:
	for property in get_property_list():
		set(property.get("name"), null)
