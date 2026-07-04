extends Node

signal task_completed
signal task_queued
signal all_completed

var _pool: Array[HTTPWorker] = []
var _queue: Array[DownloadTask] = []

var _pool_size: int

var total_to_download: int = 0
var total_downloaded: int = 0

func _ready() -> void:
	_pool_size = MCLauncherKitSettings.get_pool_size()
	for i in _pool_size:
		var worker := HTTPWorker.new()
		worker.complete_task = complete_task
		add_child(worker)
		_pool.append(worker)

func download(task: DownloadTask) -> DownloadTask:
	_queue.append(task)
	if not task.already_added:
		total_to_download += task.size
	task_queued.emit()
	_try_dispatch()
	return task

func _try_dispatch() -> void:
	for worker: HTTPWorker in _pool:
		if _queue.is_empty(): break
		if worker.is_available():
			#_start(worker, _queue.pop_front())
			worker.start(_queue.pop_front())

#func _start(worker: HTTPWorker, task: DownloadTask) -> void:
	#worker.busy = true
	#if not task.destination.is_empty():
		#if FileAccess.file_exists(task.destination) and await task.verify_sha1():
			#var body := PackedByteArray()
			#if task.keep_body:
				#var file = FileAccess.open(task.destination, FileAccess.READ)
				#body = file.get_buffer(file.get_length())
			#
			#worker.busy = false
			#complete_task(HTTPRequest.RESULT_SUCCESS, 200, body, task)
			#_try_dispatch()
			#return
		#
		#DirAccess.make_dir_recursive_absolute(task.destination.get_base_dir())
	#
	#worker.request_completed.connect(_on_download_done.bind(worker, task), CONNECT_ONE_SHOT)
	#worker.download_file = task.destination
	#worker.request(task.url)

#func _on_download_done(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, worker: HTTPWorker, task: DownloadTask) -> void:
	#if response_code in [301, 302, 307, 308]: # Redirection
		#var location := _get_header(headers, "Location")
		#if not location.is_empty():
			#Log.info("Redirect %s to %s" % [task, location])
			#task.url = location
			#_start(worker, task)
			#return
	#
	#if result == HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
		#Log.error("Handshake error for %s" % task)
		#if task.retry_allowed():
			#Log.info("Retry the download after a handshake error")
			#task.take_retry()
			#_start(worker, task)
			#return
		#Log.error("No retry available, stop here")
	#
	#worker.busy = false
	#complete_task(result, response_code, body, task)
	#_try_dispatch()

func complete_task(result: int, response_code: int, body: PackedByteArray, task: DownloadTask) -> void:
	_try_dispatch()
	Log.info("%s completed" % task)
	
	if task.keep_body:
		var file = FileAccess.open(task.destination, FileAccess.READ)
		body = file.get_buffer(file.get_length())
	
	total_downloaded += task.size
	task._complete(result, response_code, body)
	task_completed.emit()
	
	if _queue.is_empty():
		all_completed.emit.call_deferred()

#func _get_header(headers: PackedStringArray, key: String) -> String:
	#for header in headers:
		#if header.to_lower().begins_with(key.to_lower() + ":"):
			#return header.substr(key.length() + 1).strip_edges()
	#return ""
