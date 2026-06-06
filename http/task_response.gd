extends RefCounted
class_name TaskResponse

var result: int
var response_code: int
var body: PackedByteArray

func _init(result: int, response_code: int, body: PackedByteArray) -> void:
	self.response_code = response_code
	self.body = body

func text() -> String:
	return body.get_string_from_utf8()

func json() -> Variant:
	return JSON.parse_string(text())
