extends MCLauncher
class_name MCProfileLauncher

@export var profile: MCProfile

func install() -> void:
	_install(profile)

func launch() -> void:
	_launch(profile)
