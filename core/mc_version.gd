extends Resource
class_name MCVersion

enum Type {
	RELEASE,
	SNAPSHOT,
	OLD_BETA,
	OLD_ALPHA
}

@export var id: String
@export var type: Type
@export var time: String
@export var release_time: String
@export var url: String
@export var sha1: String
@export var compliance_level: int

func _to_string() -> String:
	return "%s[%s]" % [id, Type.find_key(type)]
