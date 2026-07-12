extends MCLauncher
class_name MCProfileLauncher

@export var profile: MCProfile

func install() -> void:
	await _install(profile)

func launch(auth: Authenticator) -> int:
	return await _launch(profile, auth)
