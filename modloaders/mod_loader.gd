@abstract
extends Resource
class_name ModLoader

@abstract func install(mc_version_id: String, java: String) -> Error
@abstract func patch_launch_config(config: LaunchConfig, profile: MCProfile) -> void
