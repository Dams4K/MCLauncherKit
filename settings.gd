@abstract
extends Object
class_name MCLauncherKitSettings

const SETTING_NAME = "mc_launcher_kit/"
const HTTP_SETTING_NAME = SETTING_NAME + "http/"
const POOL_SIZE_SETTING_NAME = HTTP_SETTING_NAME + "pool_size"

const DEFAULT_POOL_SIZE := 8


static func get_pool_size() -> int:
	return ProjectSettings.get_setting(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)


#region Setup
static func add_settings() -> void:
	ProjectSettings.set_setting(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)
	ProjectSettings.set_initial_value(POOL_SIZE_SETTING_NAME, DEFAULT_POOL_SIZE)
	ProjectSettings.add_property_info({
		"name": POOL_SIZE_SETTING_NAME,
		"type": TYPE_INT,
	})

static func remove_settings() -> void:
	ProjectSettings.set_setting(POOL_SIZE_SETTING_NAME, null)
#endregion
