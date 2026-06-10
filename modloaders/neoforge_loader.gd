extends ModLoader
class_name NeoforgeLoader

const INSTALLER_URL = "https://maven.neoforged.net/releases/net/neoforged/neoforge/{version}/neoforge-{version}-installer.jar"

@export var version: String
@export var sha1: String

func install(mc_version_id: String, java: String) -> Error:
	var installer_path := MCLauncherKitSettings.get_libraries_folder().path_join("installers").path_join("neoforge-%s-installer.jar" % version)
	
	var task := DownloadTask.new()
	task.url         = INSTALLER_URL.format({"version": version})
	task.sha1        = sha1
	task.destination = installer_path
	
	await HTTPClientPool.download(task).completed
	
	var reader := ZIPReader.new()
	var zip_err := reader.open(installer_path)
	if zip_err != OK:
		Log.error("Fail to read %s" % installer_path)
		return FAILED
	
	var version_path: String = MCLauncherKitSettings.get_version_json_path("neoforge-%s" % version)
	
	var version_bytes := reader.read_file("version.json")
	var version_data: Dictionary = JSON.parse_string(version_bytes.get_string_from_utf8())
	var installer_data: Dictionary = JSON.parse_string(reader.read_file("install_profile.json").get_string_from_utf8())
	
	# Extract data folder
	extract_folder(reader, "data/", installer_path.get_basename())
	
	reader.close()
	
	await DownloadTask.wait_all(AssetManager.download_libraries(version_data.libraries))
	await DownloadTask.wait_all(AssetManager.download_libraries(installer_data.libraries))
	
	if FileAccess.file_exists(version_path):
		Log.info("Neoforge %s is already installed. Only libraries are checked" % version)
		return OK
	
	var proc_err = await _run_processors(installer_data, installer_path, mc_version_id, java)
	if proc_err == OK:
		DirAccess.make_dir_recursive_absolute(version_path.get_base_dir())
		var version_file := FileAccess.open(version_path, FileAccess.WRITE)
		version_file.store_buffer(version_bytes)
		return OK
	
	Log.debug("Processors failed")
	return FAILED

func _run_processors(installer_data: Dictionary, installer_path: String, mc_version_id: String, java: String) -> Error:
	var result := OK
	
	var context := {
		"root": MCLauncherKitSettings.get_default_mc_dir(), # Use setting
		"installer": installer_path,
		"installer_data": installer_path.get_basename(),
		"minecraft_jar": MCLauncherKitSettings.get_version_jar_path(mc_version_id),
		"library_dir": MCLauncherKitSettings.get_libraries_folder(),
	}
	
	var libraries: Dictionary[String, String] = {}
	for library: Dictionary in installer_data.libraries:
		var path: String = library.get("downloads", {}).get("artifact", {}).get("path", "")
		if path.is_empty(): continue
		libraries[library.name] = path
	
	for processor: Dictionary in installer_data.get("processors", []):
		if processor.has("sides") and not "client" in processor["sides"]:
			continue
		
		var executor := JavaExecutor.new(java)
		
		var jar = MCLauncherKitSettings.get_libraries_folder().path_join(libraries[processor.jar])
		executor.add_jar(jar)
		var main_class = _get_main_class(jar)
		
		for cp: String in processor.classpath:
			executor.add_jar(MCLauncherKitSettings.get_libraries_folder().path_join(libraries[cp]))
		
		var args := _resolve_args(processor.args, context, installer_data.data, "client")
		
		var output := []
		var exit_code := executor.execute(main_class, args, output)
		
		if exit_code != 0:
			Log.error("Failed to execute processor %s" % processor)
			result = FAILED
		for out in output:
			Log.info("OUT : %s" % out)
	
	return result


static func _resolve_args(args: Array, context: Dictionary, data: Dictionary, side: String) -> Array[String]:
	var resolved: Array[String] = []
	for arg: String in args:
		var result := arg
		
		# Variables de contexte
		result = result.format({
			"ROOT": context.root,
			"INSTALLER": context.installer,
			"MINECRAFT_JAR": context.minecraft_jar,
			"LIBRARY_DIR": context.library_dir,
			"SIDE": side,
		})
		
		for key: String in data:
			var placeholder := "{%s}" % key
			if placeholder in result:
				var value: String = data[key][side]
				
				if value.begins_with("[") and value.ends_with("]"):
					value = _maven_notation_to_path(value.substr(1, value.length() - 2), context.library_dir)
					Log.debug("MVN(%s): %s" % [key, value])
				result = result.replace(placeholder, value)
		
		if result.begins_with("[") and result.ends_with("]"):
			result = _maven_notation_to_path(
				result.substr(1, result.length() - 2),
				context.library_dir
			)
		
		if result.begins_with("/data"):
			result = context.installer_data.path_join(result.trim_prefix("/"))
			Log.debug("DATA %s" % result)
		
		resolved.append(result)
	return resolved


static func _maven_notation_to_path(notation: String, library_dir: String) -> String:
	# "net.neoforged:neoform:1.21.1-20240808.144430:mappings@txt"
	# → libraries/net/neoforged/neoform/1.21.1-20240808.144430/neoform-1.21.1-20240808.144430-mappings.txt
	var ext := "jar"
	var coords := notation
	if "@" in notation:
		var parts := notation.split("@")
		coords = parts[0]
		ext = parts[1]
	
	var segments := coords.split(":")
	var group    := segments[0].replace(".", "/")
	var artifact := segments[1]
	var version  := segments[2]
	var classifier := segments[3] if segments.size() > 3 else ""
	
	var filename := "%s-%s" % [artifact, version]
	if not classifier.is_empty():
		filename += "-%s" % classifier
	filename += ".%s" % ext
	
	return library_dir.path_join("%s/%s/%s/%s" % [group, artifact, version, filename])


static func _get_main_class(jar_path: String) -> String:
	Log.debug(jar_path)
	var zip := ZIPReader.new()
	var err = zip.open(jar_path)
	assert(err == OK, "Failed to open zip %s (%s)" % [jar_path, err])
	var manifest := zip.read_file("META-INF/MANIFEST.MF").get_string_from_utf8()
	zip.close()
	
	for line in manifest.split("\n"):
		if line.begins_with("Main-Class:"):
			return line.split(":")[1].strip_edges()
	
	return ""

func extract_folder(reader: ZIPReader, from: String, to: String):
	DirAccess.make_dir_recursive_absolute(to)
	var root_dir = DirAccess.open(to)
	
	var files = reader.get_files()
	for file_path in files:
		if file_path.ends_with("/"): continue
		if not file_path.begins_with(from): continue
		
		var extracted_path := root_dir.get_current_dir().path_join(file_path)
		
		root_dir.make_dir_recursive(extracted_path.get_base_dir())
		var file = FileAccess.open(extracted_path, FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)


func patch_launch_config(config: LaunchConfig, profile: MCProfile) -> void:
	var version_path: String = MCLauncherKitSettings.get_version_json_path("neoforge-%s" % version)
	var manifest := JSON.parse_string(FileAccess.open(version_path, FileAccess.READ).get_as_text())
	var separator: String = ";" if OS.get_name() == "Windows" else ":"
	
	var formatter: Dictionary[String, String] = {
		"version_name": profile.version.id,
		"library_directory": MCLauncherKitSettings.get_libraries_folder().trim_suffix("/"),
		"classpath_separator": separator
	}
	
	var formatted_jvm: Array[String] = []
	for arg: String in manifest.arguments.jvm:
		formatted_jvm.append(arg.replace("$", "").format(formatter))
	
	var p_paths: String = formatted_jvm.get(formatted_jvm.find("-p")+1)
	
	for library in manifest.libraries:
		if not AssetManager.should_include_library(library): continue
		var path: String = MCLauncherKitSettings.get_libraries_folder().path_join(library.downloads.artifact.path)
		if path in config.classpath: continue
		
		config.classpath.append(path)
		if OS.has_feature("debug") and not FileAccess.file_exists(path):
			Log.error("File %s don't exist" % path)
	
	config.main_class = manifest.mainClass
	config.jvm_args.append_array(formatted_jvm)
	config.game_args.append_array(manifest.arguments.game)
