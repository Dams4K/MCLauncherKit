extends RefCounted
class_name DownloadTask

signal completed(response: TaskResponse)

var url: String
var destination: String = ""
var sha1: String
var size: int

var keep_body := false
var already_added := false

var _is_completed := false
var _last_response: TaskResponse

var _allowed_retries := 5

func _complete(result: int, response_code: int, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Log.error("%s failed - result: %s\t response code: %s" % [self, result, response_code])
	
	_is_completed = true
	_last_response = TaskResponse.new(
		result, response_code,
		body if destination.is_empty() or keep_body else PackedByteArray()
	)
	completed.emit.call_deferred(_last_response)


func verify_sha1() -> bool:
	return await Hasher.async_hash_file(destination, HashingContext.HASH_SHA1) == sha1


func wait() -> TaskResponse:
	if _is_completed:
		return _last_response
	return await completed


static func body_as_text(body: PackedByteArray) -> String:
	return body.get_string_from_utf8()

static func body_as_json(body: PackedByteArray) -> Variant:
	return JSON.parse_string(body_as_text(body))


static func wait_all(tasks: Array[DownloadTask]) -> void:
	for task: DownloadTask in tasks:
		if task == null: continue
		await task.wait()


func _to_string() -> String:
	if destination.is_empty():
		return "DownloadTask(%s)" % url
	return     "DownloadTask(%s, %s)" % [url, destination]


func retry_allowed() -> bool:
	return _allowed_retries > 0

func take_retry() -> void:
	_allowed_retries -= 1
