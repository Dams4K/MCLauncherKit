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

func execute(main_class: String, args: Array[String] = [], output: Array = []) -> int:
	var separator := ";" if OS.get_name() == "Windows" else ":"
	var full_args := jvm_args + ["-cp", separator.join(_classpath)]
	
	full_args.append(main_class)
	full_args.append_array(args)
	
	Log.info(full_args)
	return OS.execute(_java_path, full_args, output, true, false)

func process(main_class: String, args: Array[String] = []) -> int:
	var separator := ";" if OS.get_name() == "Windows" else ":"
	var full_args := jvm_args + ["-cp", separator.join(_classpath)]
	
	full_args.append(main_class)
	full_args.append_array(args)
	
	Log.info(full_args)
	return OS.create_process(_java_path, full_args, false)
