extends RefCounted
class_name LaunchConfig

var java_path: String
var jvm_args: Array[String] = []
var classpath: Array[String] = []
var main_class: String
var game_args: Array[String] = []
var working_directory: String
var natives_directory: String
var assets_directory: String
var asset_index: String
var version_id: String
var auth: Authenticator
var type: String = "release"

func launch() -> int:
	var executor := JavaExecutor.new(java_path)
	executor.jvm_args = jvm_args
	executor._classpath = classpath
	
	var global_game_directory := ProjectSettings.globalize_path(working_directory)
	
	var formatter: Dictionary[String, String] = {
		"version_name": version_id,
		"game_directory": global_game_directory,
		"assets_root": assets_directory,
		"assets_index_name": asset_index,
		"auth_player_name": auth.username(),
		"auth_uuid": auth.uuid(),
		"auth_access_token": auth.access_token(),
		"clientid": auth.client_id(),
		"auth_xuid": auth.xuid(),
		"user_type": auth.type(),
		"version_type": type
	}
	var formatted_args: Array[String] = []
	for arg: String in game_args:
		formatted_args.append(arg.replace("$", "").format(formatter))
	
	var code: int
	code = executor.spawn(global_game_directory, main_class, formatted_args)
	Log.info("Launch return code: %s" % code)
	return code
