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
	
	var java: String = await JavaManager.resolve(manifest.javaVersion)
	
	# Install the modloader
	if profile.modloader:
		var err = await profile.modloader.install(profile.version.id, java)
		if err != OK:
			Log.error("Modloader installation failed")
			return
	
	Log.info("Ready to launch")


func _launch(profile: MCProfile, auth: Authenticator) -> int:
	var manifest: Dictionary = await MojangAPI.fetch_version_manifest(profile.version)
	
	var config := LaunchConfig.new()
	config.java_path          = await JavaManager.resolve(manifest.javaVersion)
	config.main_class         = manifest.mainClass
	config.asset_index        = manifest.assetIndex.id
	config.assets_directory   = MCLauncherKitSettings.get_assets_folder()
	config.working_directory  = profile.game_directory if not profile.game_directory.is_empty() \
								else MCLauncherKitSettings.get_default_mc_dir()
	config.version_id         = profile.version.id
	config.jvm_args           = profile.jvm_args.duplicate()
	config.type = manifest.type
	#config.natives_directory  = MCLauncherKitSettings.get_default_mc_dir() \
								#.path_join("%s/natives" % profile.version.id)
	for arg in manifest.arguments.game:
		if arg is String:
			config.game_args.append(arg)
	
	config.auth = auth
	
	for library in manifest.libraries:
		if not AssetManager.should_include_library(library): continue
		config.classpath.append(MCLauncherKitSettings.get_libraries_folder().path_join(library.downloads.artifact.path))
	config.classpath.append(MCLauncherKitSettings.get_version_jar_path(profile.version.id))
	
	if profile.modloader:
		await profile.modloader.patch_launch_config(config, profile)
	
	return config.launch()
