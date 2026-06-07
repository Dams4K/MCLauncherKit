@abstract
extends Object
class_name MCLauncherKitSettings

const SETTING_NAME = "mc_launcher_kit/"
const HTTP_SETTING_NAME      = SETTING_NAME + "web/"
const POOL_SIZE_SETTING_NAME = HTTP_SETTING_NAME + "pool_size"
const JAVA_RUNTIME_URL_NAME  = HTTP_SETTING_NAME + "java_runtime_url"

const PATHS_SETTING_NAME  = SETTING_NAME + "paths/"
const LIBRARIES_PATH_NAME = PATHS_SETTING_NAME + "libraries_dir"
const ASSETS_PATH_NAME    = PATHS_SETTING_NAME + "assets_dir"
const VERSIONS_PATH_NAME  = PATHS_SETTING_NAME + "versions_dir"
const RUNTIMES_PATH_NAME  = PATHS_SETTING_NAME + "runtimes"

const DEFAULT_POOL_SIZE := 16
const DEFAULT_JAVA_RUNTIME := "https://launchermeta.mojang.com/v1/products/java-runtime/2ec0cc96c44e5a76b9c8b7c39df7210883d12871/all.json"

const DEFAULT_MINECRAFT_FOLDER = "mc://"
const DEFAULT_LIBRARIES_FOLDER = DEFAULT_MINECRAFT_FOLDER + "libraries/"
const DEFAULT_ASSETS_FOLDER = DEFAULT_MINECRAFT_FOLDER + "assets/"
const DEFAULT_VERSIONS_FOLDER = DEFAULT_MINECRAFT_FOLDER + "versions/{version_id}/{version_id}.{ext}"
const DEFAULT_RUNTIME_FOLDER = DEFAULT_MINECRAFT_FOLDER + "runtime/{component}"

static func get_pool_size() -> int:
	return ProjectSettings.get_setting(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)

static func get_java_runtime_url() -> String:
	return ProjectSettings.get_setting(JAVA_RUNTIME_URL_NAME, DEFAULT_JAVA_RUNTIME)


static func get_libraries_folder() -> String:
	var path: String = ProjectSettings.get_setting(LIBRARIES_PATH_NAME, DEFAULT_LIBRARIES_FOLDER)
	path = _interpret_mc_path(path)
	return ProjectSettings.globalize_path(path)

static func get_assets_folder() -> String:
	var path: String = ProjectSettings.get_setting(ASSETS_PATH_NAME, DEFAULT_ASSETS_FOLDER)
	path = _interpret_mc_path(path)
	return ProjectSettings.globalize_path(path)

static func get_versions_folder() -> String:
	var path: String = ProjectSettings.get_setting(VERSIONS_PATH_NAME, DEFAULT_VERSIONS_FOLDER)
	path = _interpret_mc_path(path)
	return ProjectSettings.globalize_path(path)

static func get_runtime_folder() -> String:
	var path: String = ProjectSettings.get_setting(RUNTIMES_PATH_NAME, DEFAULT_RUNTIME_FOLDER)
	path = _interpret_mc_path(path)
	return ProjectSettings.globalize_path(path)


static func get_version_jar_path(version_id: String) -> String:
	return get_versions_folder().format({"version_id": version_id, "ext": "jar"})

static func get_version_json_path(version_id: String) -> String:
	return get_versions_folder().format({"version_id": version_id, "ext": "json"})

static func _interpret_mc_path(path: String) -> String:
	var data_dir := get_default_mc_dir()
	if not data_dir.ends_with("/"):
		data_dir += "/"
	return path.replace("mc://", data_dir)

static func get_default_mc_dir() -> String:
	match OS.get_name():
		"Windows":
			return OS.get_environment("APPDATA") + "/.minecraft"
		"macOS":
			return OS.get_environment("HOME") + "/Library/Application Support/minecraft"
		_:  # Linux
			return OS.get_environment("HOME") + "/.minecraft"

#region Setup
static func add_settings() -> void:
	ProjectSettings.set_setting(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)
	ProjectSettings.set_initial_value(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)
	ProjectSettings.add_property_info({
		"name": POOL_SIZE_SETTING_NAME,
		"type": TYPE_INT,
	})
	
	ProjectSettings.set_setting(JAVA_RUNTIME_URL_NAME, DEFAULT_JAVA_RUNTIME)
	ProjectSettings.set_initial_value(JAVA_RUNTIME_URL_NAME, DEFAULT_JAVA_RUNTIME)
	ProjectSettings.add_property_info({
		"name": JAVA_RUNTIME_URL_NAME,
		"type": TYPE_STRING,
	})
	
	ProjectSettings.set_setting(LIBRARIES_PATH_NAME, DEFAULT_LIBRARIES_FOLDER)
	ProjectSettings.set_initial_value(LIBRARIES_PATH_NAME, DEFAULT_LIBRARIES_FOLDER)
	ProjectSettings.add_property_info({
		"name": LIBRARIES_PATH_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})
	
	ProjectSettings.set_setting(ASSETS_PATH_NAME, DEFAULT_ASSETS_FOLDER)
	ProjectSettings.set_initial_value(ASSETS_PATH_NAME, DEFAULT_ASSETS_FOLDER)
	ProjectSettings.add_property_info({
		"name": ASSETS_PATH_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})
	
	ProjectSettings.set_setting(VERSIONS_PATH_NAME, DEFAULT_VERSIONS_FOLDER)
	ProjectSettings.set_initial_value(VERSIONS_PATH_NAME, DEFAULT_VERSIONS_FOLDER)
	ProjectSettings.add_property_info({
		"name": VERSIONS_PATH_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})
	
	ProjectSettings.set_setting(RUNTIMES_PATH_NAME, DEFAULT_RUNTIME_FOLDER)
	ProjectSettings.set_initial_value(RUNTIMES_PATH_NAME, DEFAULT_RUNTIME_FOLDER)
	ProjectSettings.add_property_info({
		"name": RUNTIMES_PATH_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})

static func remove_settings() -> void:
	ProjectSettings.set_setting(POOL_SIZE_SETTING_NAME, null)
	ProjectSettings.set_setting(JAVA_RUNTIME_URL_NAME, null)
	ProjectSettings.set_setting(LIBRARIES_PATH_NAME, null)
	ProjectSettings.set_setting(ASSETS_PATH_NAME, null)
	ProjectSettings.set_setting(VERSIONS_PATH_NAME, null)
	ProjectSettings.set_setting(RUNTIMES_PATH_NAME, null)
#endregion
