@abstract
extends Object
class_name MCLauncherKitSettings

const SETTING_NAME = "mc_launcher_kit/"
const HTTP_SETTING_NAME      = SETTING_NAME + "http/"
const POOL_SIZE_SETTING_NAME = HTTP_SETTING_NAME + "pool_size"

const PATHS_SETTING_NAME  = SETTING_NAME + "paths/"
const LIBRARIES_PATH_NAME = PATHS_SETTING_NAME + "libraries_dir"
const ASSETS_PATH_NAME    = PATHS_SETTING_NAME + "assets_dir"

const DEFAULT_POOL_SIZE := 8

const DEFAULT_MINECRAFT_FOLDER = "mc://"
const DEFAULT_LIBRARIES_FOLDER = DEFAULT_MINECRAFT_FOLDER + "libraries/"
const DEFAULT_ASSETS_FOLDER = DEFAULT_MINECRAFT_FOLDER + "assets/"


static func get_pool_size() -> int:
	return ProjectSettings.get_setting(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)

static func get_libraries_folder() -> String:
	var path: String = ProjectSettings.get_setting(LIBRARIES_PATH_NAME, DEFAULT_LIBRARIES_FOLDER)
	path = _interpret_mc_path(path)
	return ProjectSettings.globalize_path(path)

static func get_assets_folder() -> String:
	var path: String = ProjectSettings.get_setting(ASSETS_PATH_NAME, DEFAULT_ASSETS_FOLDER)
	path = _interpret_mc_path(path)
	return ProjectSettings.globalize_path(path)


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
	
	#var default_mc := OS.get_data_dir().path_join(DEFAULT_MINECRAFT_FOLDER)
	
	var default_libraries_path := DEFAULT_LIBRARIES_FOLDER
	ProjectSettings.set_setting(LIBRARIES_PATH_NAME, default_libraries_path)
	ProjectSettings.set_initial_value(LIBRARIES_PATH_NAME, default_libraries_path)
	ProjectSettings.add_property_info({
		"name": LIBRARIES_PATH_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})
	
	var default_assets_path := DEFAULT_ASSETS_FOLDER
	ProjectSettings.set_setting(ASSETS_PATH_NAME, default_assets_path)
	ProjectSettings.set_initial_value(ASSETS_PATH_NAME, default_assets_path)
	ProjectSettings.add_property_info({
		"name": ASSETS_PATH_NAME,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})

static func remove_settings() -> void:
	ProjectSettings.set_setting(POOL_SIZE_SETTING_NAME, null)
	ProjectSettings.set_setting(LIBRARIES_PATH_NAME, null)
	ProjectSettings.set_setting(ASSETS_PATH_NAME, null)
#endregion
