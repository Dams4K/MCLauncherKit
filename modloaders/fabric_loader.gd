extends ModLoader
class_name FabricLoader

func install(mc_version_id: String, java: String) -> Error:
	return FAILED

func patch_launch_config(config: LaunchConfig, profile: MCProfile) -> void:
	pass
