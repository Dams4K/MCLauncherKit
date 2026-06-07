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


static func download_assets(asset_index: Dictionary) -> void:
	var id: String      = asset_index.id
	var sha1: String    = asset_index.sha1
	var size: int       = asset_index.size
	var total_size: int = asset_index.totalSize # sum all of assets size
	var url: String     = asset_index.url
	
	#HTTPClientPool.total_to_download += total_size # Must had a variable in TaskDownload to don't readd it when we do HTTPClientPool.download
	
	var task := DownloadTask.new()
	task.url = url
	task.size = int(size)
	task.sha1 = sha1
	task.destination = MCLauncherKitSettings.get_assets_folder().path_join("%s.json" % id)
	task.keep_body = true
	
	var response: TaskResponse = await HTTPClientPool.download(task).completed
	var index: Dictionary = response.json()
	
	for asset_id in index.objects:
		var asset = index.objects[asset_id]
		_download_asset(asset)


static func _download_asset(asset: Dictionary) -> void:
	var sha1: String = asset.hash
	var size: int = asset.size
	
	var path := MCLauncherKitSettings.get_assets_folder().path_join("objects").path_join(sha1.substr(0, 2)).path_join(sha1)
	
	var task := DownloadTask.new()
	task.sha1        = sha1
	task.size        = size
	task.url         = MojangAPI.get_asset_url(sha1)
	task.destination = path
	
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
