extends Node
class_name GameSave

@export var player_cnt: int
@export var player_index: int
@export var round_i: int

@export var players: Dictionary[int, Player] = {}

@export var jackpot: int = 1500

@export var MISTRAK: int = 3 # number of "mistraks" before being thrown out of the game
@export var NULY: int = 3 # number of zeros in general before zeroing out

static func from_game(player_cnt: int, player_index: int, round_i: int, players: Dictionary[int, Player], jackpot: int, mistrak: int, nuly: int) -> GameSave:
	var save = GameSave.new()
	save.player_cnt = player_cnt
	save.player_index = player_index
	save.round_i = round_i
	save.players = players
	save.jackpot = jackpot
	save.MISTRAK = mistrak
	save.NULY = nuly
	return save

func to_save_json() -> String:
	var save_string = JsonClassConverter.class_to_json_string(self)
	return save_string

static func from_json_string(json: String):
	var game: GameSave = JsonClassConverter.json_string_to_class(GameSave, json)
	return game
