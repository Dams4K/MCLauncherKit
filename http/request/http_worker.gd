extends HTTPRequest
class_name HTTPWorker

var _busy := false
var complete_task: Callable

func is_available() -> bool:
	return not _busy and get_http_client_status() == HTTPClient.STATUS_DISCONNECTED

func start(task: DownloadTask) -> void:
	_busy = true
	if not task.destination.is_empty():
		if FileAccess.file_exists(task.destination) and await task.verify_sha1():
			var body := PackedByteArray()
			if task.keep_body:
				var file = FileAccess.open(task.destination, FileAccess.READ)
				body = file.get_buffer(file.get_length())
			
			complete(HTTPRequest.RESULT_SUCCESS, 200, body, task)
			return
		
		DirAccess.make_dir_recursive_absolute(task.destination.get_base_dir())
	
	request_completed.connect(_on_download_done.bind(task), CONNECT_ONE_SHOT)
	download_file = task.destination
	request(task.url)


func _on_download_done(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, task: DownloadTask) -> void:
	if response_code in [301, 302, 307, 308]: # Redirection
		var location := _get_header(headers, "Location")
		if not location.is_empty():
			Log.info("Redirect %s to %s" % [task, location])
			task.url = location
			start(task)
			return
	
	if result == HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
		Log.error("Handshake error for %s" % task)
		if task.retry_allowed():
			Log.info("Retry the download after a handshake error")
			task.take_retry()
			start(task)
			return
		Log.error("No retry available, stop here")
	
	complete(result, response_code, body, task)


func complete(result: int, response_code: int, body: PackedByteArray, task: DownloadTask) -> void:
	_busy = false
	complete_task.call(result, response_code, body, task)


func _get_header(headers: PackedStringArray, key: String) -> String:
	for header in headers:
		if header.to_lower().begins_with(key.to_lower() + ":"):
			return header.substr(key.length() + 1).strip_edges()
	return ""
