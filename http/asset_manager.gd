@abstract
extends Object
class_name AssetManager

static func download_libraries(libraries: Array) -> void:
	for library in libraries:
		_download_library(library)

static func _download_library(library: Dictionary) -> void:
	if not should_include_library(library): return
	
	var path: String = library.downloads.artifact.path
	var sha1: String = library.downloads.artifact.sha1
	var size: int = library.downloads.artifact.size
	var url: String = library.downloads.artifact.url
	
	var task := DownloadTask.new()
	task.url = url
	task.size = size
	task.sha1 = sha1
	task.destination = MCLauncherKitSettings.get_libraries_folder().path_join(path)
	
	HTTPClientPool.download(task)


static func should_include_library(library: Dictionary) -> bool:
	if not library.has("rules"):
		return true
	for rule in library["rules"]:
		var action = rule["action"] == "allow"
		if rule.has("os"):
			var matches_os = rule["os"]["name"] == _get_current_os()
			if action != matches_os:
				return false
		if rule.has("features"):
			return false
	return true

static func _get_current_os() -> String:
	match OS.get_name():
		"Windows": return "windows"
		"macOS": return "osx"
		_: return "linux"
