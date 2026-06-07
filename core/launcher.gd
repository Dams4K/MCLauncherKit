extends Node
class_name MCLauncher

@export var loader: GameLoader

func install(profile: MCProfile) -> void:
	var manifest: Dictionary = await MojangAPI.fetch_version_manifest(profile.version)
	
	AssetManager.download_libraries(manifest["libraries"])
	AssetManager.download_assets(manifest["assetIndex"])


#https://maven.neoforged.net/releases/net/neoforged/neoforge/maven-metadata.xml
#https://maven.neoforged.net/releases/net/neoforged/neoforge/{version}/neoforge-{version}-installer.jar
#https://maven.minecraftforge.net/net/minecraftforge/forge/maven-metadata.xml
#https://maven.minecraftforge.net/net/minecraftforge/forge/{mc_version}-{forge_version}/forge-{mc_version}-{forge_version}-installer.jar

#https://maven.neoforged.net/releases/net/neoforged/neoforge/21.1.233/neoforge-21.1.233-installer.jar
#https://maven.minecraftforge.net/net/minecraftforge/forge/1.21-51.0.33/forge-1.21-51.0.33-installer.jar
#1.21.1-52.1.2
