extends Node
class_name MCLauncher

@export var loader: GameLoader

func install(profile: MCProfile) -> void:
	var manifest: Dictionary = await MojangAPI.fetch_version_manifest(profile.version)
