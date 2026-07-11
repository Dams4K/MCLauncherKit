extends RefCounted
class_name JavaExecutor

var jvm_args: Array[String] = []
var _java_path: String
var _classpath: Array[String] = []

func _init(java: String) -> void:
	self._java_path = java

func add_jar(path: String) -> JavaExecutor:
	_classpath.append(path)
	return self

func run(working_dir: String, main_class: String, args: Array[String] = []) -> Dictionary:
	var separator := ";" if OS.get_name() == "Windows" else ":"
	var full_args := jvm_args + ["-cp", separator.join(_classpath)]
	
	full_args.append(main_class)
	full_args.append_array(args)
	
	Log.debug("%s %s" % [_java_path, " ".join(full_args)])
	return Java.run(working_dir, _java_path, full_args)

func spawn(working_dir: String, main_class: String, args: Array[String] = []) -> Error:
	var separator := ";" if OS.get_name() == "Windows" else ":"
	var full_args := jvm_args + ["-cp", separator.join(_classpath)]
	
	full_args.append(main_class)
	full_args.append_array(args)
	
	Log.debug("%s %s" % [_java_path, " ".join(full_args)])
	return Java.spawn(working_dir, _java_path, full_args)
