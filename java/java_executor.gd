extends RefCounted
class_name JavaExecutor

var java_path: String
var classpath: Array[String] = []
var jvm_args: Array[String] = []

func _init(java: String) -> void:
	self.java_path = java

func add_jar(path: String) -> JavaExecutor:
	classpath.append(path)
	return self

func execute(main_class: String, args: Array[String], output: Array = []) -> int:
	var separator := ";" if OS.get_name() == "Windows" else ":"
	var full_args := jvm_args + ["-cp", separator.join(classpath)]
	
	full_args.append(main_class)
	full_args.append_array(args)
	
	Log.info(full_args)
	return OS.execute(java_path, full_args, output, true, false)
