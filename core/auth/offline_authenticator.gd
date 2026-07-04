extends Authenticator
class_name OfflineAuthenticator

var _username: String = "Dev"

func _init(name: String = ""):
	if not name.is_empty():
		_username = name

func username() -> String:
	return _username

func uuid() -> String:
	return "00000000-0000-0000-0000-000000000000"

func access_token() -> String:
	return "0"

func client_id() -> String:
	return "0"

func xuid() -> String:
	return "0"

func type() -> String:
	return "mojang"
