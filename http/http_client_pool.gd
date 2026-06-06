extends Node

signal task_completed

var _pool: Array[HTTPRequest] = []
var _queue: Array[DownloadTask] = []

var _pool_size: int

func _ready() -> void:
	_pool_size = MCLauncherKitSettings.get_pool_size()
	for i in _pool_size:
		var http := HTTPRequest.new()
		add_child(http)
		_pool.append(http)

func download(task: DownloadTask) -> DownloadTask:
	_queue.append(task)
	_try_dispatch()
	return task

func _try_dispatch() -> void:
	for http: HTTPRequest in _pool:
		if _queue.is_empty(): break
		if http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
			_start(http, _queue.pop_front())

func _start(http: HTTPRequest, task: DownloadTask) -> void:
	http.request_completed.connect(_on_download_done.bind(http, task), CONNECT_ONE_SHOT)
	http.request(task.url)

func _on_download_done(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, task: DownloadTask) -> void:
	Log.debug("Task(%s) completed" % task.url)
	task._complete(result, response_code, body)
	_try_dispatch()
