@tool
extends EditorPlugin

const HTTP_CLIENT_POOL = "HTTPClientPool"

func _enable_plugin() -> void:
	add_autoload_singleton(HTTP_CLIENT_POOL, get_plugin_file("http/http_client_pool.gd"))
	MCLauncherKitSettings.add_settings()

func _disable_plugin() -> void:
	remove_autoload_singleton(HTTP_CLIENT_POOL)
	MCLauncherKitSettings.remove_settings()


func get_plugin_dir() -> String:
	return get_script().resource_path.get_base_dir()

func get_plugin_file(relative_path: String) -> String:
	return get_plugin_dir().path_join(relative_path)
