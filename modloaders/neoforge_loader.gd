extends ModLoader
class_name NeoforgeLoader

const INSTALLER_URL = "https://maven.neoforged.net/releases/net/neoforged/neoforge/{version}/neoforge-{version}-installer.jar"

@export var version: String
@export var sha1: String

func install(_mc_version_id: String) -> void:
	#var version := "%s.%s" % [mc_version_id, version]
	var installer_path := MCLauncherKitSettings.get_libraries_folder().path_join("installers").path_join("neoforge-%s-installer.jar" % version)
	
	var task := DownloadTask.new()
	task.url         = INSTALLER_URL.format({"version": version})
	task.sha1        = sha1
	task.destination = installer_path
	
	await HTTPClientPool.download(task).completed
	
	var reader := ZIPReader.new()
	var err := reader.open(installer_path)
	if err != OK:
		Log.error("Fail to read %s" % installer_path)
		return
	
	var installer_data: Dictionary = JSON.parse_string(reader.read_file("install_profile.json").get_string_from_utf8())
	print(installer_data["processors"])
	reader.close()

func patch_launch_config(config: LaunchConfig, profile: MCProfile) -> void:
	pass
