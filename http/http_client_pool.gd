extends Node

signal task_completed
signal task_queued
signal all_completed

var _pool: Array[HTTPRequest] = []
var _queue: Array[DownloadTask] = []

var _pool_size: int

var total_to_download: int = 0
var total_downloaded: int = 0

func _ready() -> void:
	_pool_size = MCLauncherKitSettings.get_pool_size()
	for i in _pool_size:
		var http := HTTPRequest.new()
		add_child(http)
		_pool.append(http)

func download(task: DownloadTask) -> DownloadTask:
	_queue.append(task)
	if not task.already_added:
		total_to_download += task.size
	task_queued.emit()
	_try_dispatch()
	return task

func _try_dispatch() -> void:
	for http: HTTPRequest in _pool:
		if _queue.is_empty(): break
		if http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			_start(http, _queue.pop_front())

func _start(http: HTTPRequest, task: DownloadTask) -> void:
	if not task.destination.is_empty():
		if FileAccess.file_exists(task.destination) and task.verify_sha1():
			var body := PackedByteArray()
			if task.keep_body:
				var file = FileAccess.open(task.destination, FileAccess.READ)
				body = file.get_buffer(file.get_length())
			
			complete_task(HTTPRequest.RESULT_SUCCESS, 200, body, task)
			return
		
		DirAccess.make_dir_recursive_absolute(task.destination.get_base_dir())
	
	http.request_completed.connect(_on_download_done.bind(http, task), CONNECT_ONE_SHOT)
	http.download_file = task.destination
	http.request(task.url)

func _on_download_done(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, task: DownloadTask) -> void:
	if response_code in [301, 302, 307, 308]: # Redirection
		var location := _get_header(headers, "Location")
		if not location.is_empty():
			Log.info("Redirect %s to %s" % [task, location])
			task.url = location
			_start(http, task)
			return
	
	complete_task(result, response_code, body, task)
	_try_dispatch()

func complete_task(result: int, response_code: int, body: PackedByteArray, task: DownloadTask) -> void:
	Log.info("%s completed" % task)
	
	if task.keep_body:
		var file = FileAccess.open(task.destination, FileAccess.READ)
		body = file.get_buffer(file.get_length())
	
	total_downloaded += task.size
	task._complete(result, response_code, body)
	task_completed.emit()
	
	if _queue.is_empty():
		all_completed.emit.call_deferred()

func _get_header(headers: PackedStringArray, key: String) -> String:
	for header in headers:
		if header.to_lower().begins_with(key.to_lower() + ":"):
			return header.substr(key.length() + 1).strip_edges()
	return ""
