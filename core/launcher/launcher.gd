@abstract
extends Node
class_name MCLauncher

func _install(profile: MCProfile) -> void:
	# Install minecraft only
	var manifest: Dictionary = await MojangAPI.fetch_version_manifest(profile.version)
	
	var tasks: Array[DownloadTask] = []
	tasks.append_array(AssetManager.download_libraries(manifest["libraries"]))
	tasks.append_array(await AssetManager.download_assets(manifest["assetIndex"]))
	tasks.append(AssetManager.download_client(manifest["downloads"]["client"], profile.version.id))
	
	await DownloadTask.wait_all(tasks)
	
	var java: String = await JavaManager.resolve(manifest["javaVersion"])
	
	# Install the modloader
	if profile.modloader:
		var err = await profile.modloader.install(profile.version.id, java)
		if err != OK:
			Log.error("Modloader installation failed")
			return
	
	Log.info("Ready to launch")


func _launch(profile: MCProfile) -> void:
	var manifest: Dictionary = await MojangAPI.fetch_version_manifest(profile.version)
	
	var config := LaunchConfig.new()
	config.main_class = manifest.mainClass
	
	if profile.modloader:
		await profile.modloader.patch_launch_config(config, profile)



#https://maven.neoforged.net/releases/net/neoforged/neoforge/maven-metadata.xml
#https://maven.neoforged.net/releases/net/neoforged/neoforge/{version}/neoforge-{version}-installer.jar
#https://maven.minecraftforge.net/net/minecraftforge/forge/maven-metadata.xml
#https://maven.minecraftforge.net/net/minecraftforge/forge/{mc_version}-{forge_version}/forge-{mc_version}-{forge_version}-installer.jar

#https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.233/neoforge-21.1.233-installer.jar
#https://maven.minecraftforge.net/net/minecraftforge/forge/1.21-51.0.33/forge-1.21-51.0.33-installer.jar
#1.21.1-52.1.2
