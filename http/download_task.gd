extends RefCounted
class_name DownloadTask

signal completed(response: TaskResponse)

var url: String
var destination: String = ""
var sha1: String
var size: int

var keep_body := false
var already_added := false

func _complete(result: int, response_code: int, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		Log.error("Task failed - result: %s\t response code: %s" % [result, response_code])
	
	completed.emit.call_deferred(TaskResponse.new(
		result, response_code,
		body if destination.is_empty() or keep_body else PackedByteArray()
	))


func verify_sha1() -> bool:
	return Hasher.hash_file(destination, HashingContext.HASH_SHA1) == sha1


static func body_as_text(body: PackedByteArray) -> String:
	return body.get_string_from_utf8()

static func body_as_json(body: PackedByteArray) -> Variant:
	return JSON.parse_string(body_as_text(body))

func _to_string() -> String:
	if destination.is_empty():
		return "DownloadTask(%s)" % url
	return     "DownloadTask(%s, %s)" % [url, destination]
