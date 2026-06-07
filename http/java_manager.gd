@abstract
extends Object
class_name JavaManager

static func resolve(java_version: Dictionary) -> String:
	var component: String  = java_version.component
	var major_version: int = java_version.majorVersion
	
	var mojang_java_path := _get_java_executable_path(component)
	if FileAccess.file_exists(mojang_java_path):
		return mojang_java_path
	
	var adoptium_java_path := _get_java_executable_path(str(major_version))
	if FileAccess.file_exists(adoptium_java_path):
		return adoptium_java_path
	
	var installed_mojang_java_path := await install_mojang_java(component)
	if FileAccess.file_exists(installed_mojang_java_path):
		return installed_mojang_java_path
	
	return await install_adoptium_java() # Last hope...

static func install_mojang_java(component: String) -> String:
	var all_runtimes_task := DownloadTask.new()
	all_runtimes_task.url = MCLauncherKitSettings.get_java_runtime_url()
	
	var all_runtimes_response: TaskResponse = await HTTPClientPool.download(all_runtimes_task).completed
	if not all_runtimes_response.ok():
		Log.warn("Fail to download all runtimes json")
		return ""
	var all_runtimes: Dictionary = all_runtimes_response.json()
	
	var os_key := _get_os_key()
	var runtime_list: Array = all_runtimes[os_key][component]
	if runtime_list.is_empty():
		Log.warn("No Java runtime found for %s / %s" % [os_key, component])
		return ""
	
	var manifest_task := DownloadTask.new()
	manifest_task.url = runtime_list[0].manifest.url
	manifest_task.sha1 = runtime_list[0].manifest.sha1
	manifest_task.size = runtime_list[0].manifest.size
	
	var manifest_response: TaskResponse = await HTTPClientPool.download(manifest_task).completed
	if not all_runtimes_response.ok():
		Log.warn("Fail to download runtime manifest")
		return ""
	var manifest: Dictionary = manifest_response.json()
	
	var executables: Array[DownloadTask] = [] # Keep reference of the tasks that must be executable for the complete signal to be listened
	for file_path: String in manifest.files:
		var file_info: Dictionary = manifest.files[file_path]
		if file_info.type != "file": continue
		
		var download_info: Dictionary = file_info.downloads.raw
		var executable: bool = file_info.executable
		
		var task := DownloadTask.new()
		task.url         = download_info.url
		task.size        = download_info.size
		task.sha1        = download_info.sha1
		task.destination = _get_java_folder(component).path_join(file_path)
		
		if executable and OS.get_name() != "Windows":
			Log.debug("CHMOD for %s" % file_path)
			executables.append(task)
			task.completed.connect(
				func(_res):
					Log.debug("chmod %s" % ProjectSettings.globalize_path(_get_java_folder(component).path_join(file_path)))
					OS.execute("chmod", ["+x", ProjectSettings.globalize_path(_get_java_folder(component).path_join(file_path))])
			)
		
		HTTPClientPool.download(task)
	
	await HTTPClientPool.all_completed
	return _get_java_executable_path(component)

static func install_adoptium_java() -> String:
	return ""


static func _get_java_folder(component: String) -> String:
	return MCLauncherKitSettings.get_runtime_folder().format({"component": component})


static func _get_java_executable_path(component: String) -> String:
	var base = _get_java_folder(component)
	match OS.get_name():
		"Windows": return base.path_join("bin/java.exe")
		"macOS":   return base.path_join("jre.bundle/Contents/Home/bin/java")
		_:         return base.path_join("bin/java")

static func _get_os_key() -> String:
	match OS.get_name():
		"Windows":
			if OS.has_feature("arm64"): return "windows-arm64"
			if OS.has_feature("64"):    return "windows-x64"
			return "windows-x86"
		"macOS":
			if OS.has_feature("arm64"): return "mac-os-arm64"
			return "mac-os"
		_:
			if OS.has_feature("64"):    return "linux"
			return "linux-i386"
