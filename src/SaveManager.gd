extends Node


func list_saves() -> Dictionary[String, int]: # first string is filepath, second is unix timestamp
	if !DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")
	var dir = DirAccess.open("user://saves")
	var files = dir.get_files()
	var regex = RegEx.new()
	regex.compile("save-([0123456789]+)")
	var ret_dict: Dictionary[String, int] = {}
	for file_path: String in files:
		var result = regex.search(file_path)
		var unixtime: int = int(result.get_string(1))
		ret_dict[file_path] = unixtime
	return ret_dict

# get_datetime_string_from_unix_time
# get_unix_time_from_system

func save_game(save_string: String) -> void:
	var time: int = Time.get_unix_time_from_system()
	var file_string: String = "user://saves/save-" + str(time)
	var file = FileAccess.open(file_string, FileAccess.WRITE)
	file.store_string(save_string)

func load_game(file_string: String) -> Variant: 
	if FileAccess.file_exists(file_string):
		var file = FileAccess.open(file_string, FileAccess.READ)
		var game_string: String = file.get_as_text()
		var game: GameSave = GameSave.from_json_string(game_string)
		return game
	return null

func delete_save(save_string: String) -> void:
	if FileAccess.file_exists(save_string):
		DirAccess.remove_absolute(save_string)
