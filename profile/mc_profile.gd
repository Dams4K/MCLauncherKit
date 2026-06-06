extends Resource
class_name MCProfile

@export var name: String
@export var version: MCVersion
@export var modloader: GameLoader
@export var authenticator: Authenticator

@export var game_directory: String
@export var java_override: String
@export var jvm_args: Array[String] = ["-Xmx4G", "-Xms2G"]
@export var resolution: Vector2i = Vector2i(1280, 720)
@export var fullscreen: bool = false
