@abstract
extends Object
class_name MojangAPI

const VERSION_MANIFEST_URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
const ASSET_URL = "https://resources.download.minecraft.net/%s/%s"

static func fetch_versions(include_snapshots: bool) -> Array[MCVersion]:
	var task := DownloadTask.new()
	task.url = VERSION_MANIFEST_URL
	
	var data: Dictionary = (await HTTPClientPool.download(task).completed).json()
	
	var versions: Array[MCVersion] = []
	for version_data: Dictionary in data.get("versions", []):
		var type = MCVersion.Type.get(version_data["type"].to_upper())
		if type == MCVersion.Type.SNAPSHOT and not include_snapshots:
			continue
		
		var version := MCVersion.new()
		version.type             = type
		version.id               = version_data["id"]
		version.url              = version_data["url"]
		version.time             = version_data["time"]
		version.release_time     = version_data["releaseTime"]
		version.sha1             = version_data["sha1"]
		version.compliance_level = version_data["complianceLevel"]
	
		versions.append(version)
	
	return versions

static func fetch_version_manifest(version: MCVersion) -> Dictionary:
	var task := DownloadTask.new()
	task.url = version.url
	task.destination = MCLauncherKitSettings.get_version_json_path(version.id)
	task.keep_body = true
	
	var data: Dictionary = (await HTTPClientPool.download(task).completed).json()
	return data


static func get_asset_url(sha1: String) -> String:
	return ASSET_URL % [sha1.substr(0, 2), sha1]
