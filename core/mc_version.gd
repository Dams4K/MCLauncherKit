extends Resource
class_name MCVersion

enum Type {
	RELEASE,
	SNAPSHOT,
	OLD_BETA,
	OLD_ALPHA
}

var id: String
var type: Type
var time: String
var release_time: String
var url: String
var sha1: String
var compliance_level: int

func _to_string() -> String:
	return "%s[%s]" % [id, Type.find_key(type)]
