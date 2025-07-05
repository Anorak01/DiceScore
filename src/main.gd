extends Control

var player_cnt: int = 2:
	get: return player_cnt
	set(value):
		player_cnt = value
		player_cnt_update.emit(value)
signal player_cnt_update(new_cnt: int)

var state: STATE = STATE.START
enum STATE {
	START,
	PLAY,
}

var player_index: int:
	get: return player_index
	set(value):
		player_index = value
		player_index_update.emit(value)
signal player_index_update(new_index: int)

var round_i: int:
	get: return round_i
	set(value):
		round_i = value
		round_index_update.emit(value)
signal round_index_update(new_index: int)

signal player_score_label_update(new_score: int)

var players: Dictionary[int, Player] = {}

var jackpot: int = 1500

var MISTRAK: int = 3 # number of "mistraks" before being thrown out of the game
var NULY: int = 3 # number of zeros in general before zeroing out


func _ready() -> void:
	# set up some defaults to make dev easier
	state = STATE.START
	$StartScreen.show()
	$PlayScreen.hide()
	$ScoreScreen.hide()
	$ScoreButton.hide()
	$LoadGameScreen.hide()
	SaveManager.list_saves()

func _on_plus_button_pressed() -> void:
	player_cnt = clamp(player_cnt + 1, 2, 10)

func _on_minus_button_pressed() -> void:
	player_cnt = clamp(player_cnt - 1, 2, 10)

func _on_start_button_pressed() -> void:
	if state != STATE.START: return # what the hell
	# start the game
	state = STATE.PLAY

	# clear out scores and initialize
	players.clear()
	for i in range(1, player_cnt + 1):
		var player = Player.new()
		player.id = i
		player.p_name = ""
		player.nulls = 0
		player.master_of_nothing = 0
		player.score = 0
		player.old_score = 0
		player.alive = true
		players[i] = player

	# set player index to 1
	player_index = 1
	round_i = 1

	player_score_label_update.emit(0)

	$StartScreen.hide()
	$PlayScreen.show()
	$ScoreButton.show()

# processes zeroing on current player, done at the end of ones turn
func process_zeroing():
	var player = players[player_index]
	if player.old_score == player.score:
		# player got a zero
		player.nulls += 1
	else:
		# if player entered some score, null counter should be reset
		player.nulls = 0
		player.master_of_nothing = 0
	
	if player.nulls >= NULY:
		# zero out the scores
		player.score = 0
		player.old_score = 0
		
		# reset the zero counter
		player.nulls = 0
		
		print("Zeroed out player: " + str(player.id))

# triggered with Next Player button
func _on_next_player_pressed() -> void:
	# process zeroing 
	process_zeroing()

	next_player()
	
	# update the old_score variable for player
	players[player_index].old_score = players[player_index].score

func _on_previous_player_pressed() -> void:
	player_index = wrap(player_index - 1, 1, player_cnt + 1)
	player_score_label_update.emit(players[player_index].score)

func score(value: int):
	if $PlayScreen/Fix.button_pressed:
		players[player_index].score -= value
	else:
		players[player_index].score += value
	player_score_label_update.emit(players[player_index].score)

func _on_jackpot_pressed() -> void:
	if $PlayScreen/Fix.button_pressed:
		players[player_index].score -= jackpot
	else:
		players[player_index].score += jackpot
	player_score_label_update.emit(players[player_index].score)


func _on_score_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$ScoreScreen/ItemList.init(players)
		$PlayScreen.hide()
		$ScoreScreen.show()
	else:
		$PlayScreen.show()
		$ScoreScreen.hide()

func reset():
	state = STATE.START
	$StartScreen.show()
	$PlayScreen.hide()
	$ScoreScreen.hide()
	$ScoreButton.hide()

func _on_reset_button_pressed() -> void:
	reset()

func _on_h_slider_value_changed(value: float) -> void:
	$StartScreen/JackpotValueLabel.text = str(int(value))
	jackpot = int(value)


func _on_nulovat_pressed() -> void:
	players[player_index].score = 0
	player_score_label_update.emit(players[player_index].score)


func _on_master_of_nothing_button_pressed() -> void:
	var player = players[player_index]
	player.master_of_nothing += 1
	if player.master_of_nothing >= MISTRAK:
		# player got nothing right of the bat a lot, they are not worthy of continuing the game
		player.alive = false
		print("killed off player " + player.id)
	process_zeroing()

	next_player()

func next_player():
	# change index and fire score label update till we find someone alive
	try_next()
	var cntr = 0
	while (!players[player_index].alive):
		try_next()
		
		# prevent infinite while loop in case something is really wrong
		cntr += 1
		if cntr >= player_cnt:
			# everyone is dead, end the game
			print("Dead game, resetting")
			reset()
			break
		
	player_score_label_update.emit(players[player_index].score)
	$PlayScreen/ZeroBar.value = players[player_index].nulls
	$PlayScreen/MasterBar.value = players[player_index].master_of_nothing


func try_next():
	if player_index == player_cnt: # do wrapping
		player_index = 1
		round_i += 1
	else: player_index += 1


func _on_save_button_pressed() -> void:
	var save: GameSave = GameSave.from_game(player_cnt, player_index, round_i, players, jackpot, MISTRAK, NULY)
	SaveManager.save_game(save.to_save_json())


func _on_load_game_button_pressed() -> void:
	# load up save list
	$LoadGameScreen/GameList.init(SaveManager.list_saves())
	# switch to load screen
	$StartScreen.hide()
	$LoadGameScreen.show()


func _on_close_load_screen_button_pressed() -> void:
	$StartScreen.show()
	$LoadGameScreen.hide()

func load_game(save: GameSave):
	self.player_cnt = save.player_cnt
	self.player_index = save.player_index
	self.round_i = save.round_i
	self.players = save.players
	self.jackpot = save.jackpot
	self.MISTRAK = save.MISTRAK
	self.NULY = save.NULY

func _on_load_game_final_button_pressed() -> void:
	if $LoadGameScreen/GameList.is_anything_selected():
		var items = $LoadGameScreen/GameList.get_selected_items()
		# items[0] should be the only selected item
		var metadata = str($LoadGameScreen/GameList.get_item_metadata(items[0]))
		var gamesave_string = "user://saves/" + metadata
		var game_save = SaveManager.load_game(gamesave_string)
		
		if game_save == null: return
		
		var game: GameSave = game_save
		load_game(game)
		
		state = STATE.PLAY
		
		player_score_label_update.emit(self.players[player_index].score)
		
		$LoadGameScreen.hide()
		$PlayScreen.show()
		$ScoreButton.show()


func _on_delete_save_pressed() -> void:
	if $LoadGameScreen/GameList.is_anything_selected():
		var items = $LoadGameScreen/GameList.get_selected_items()
		# items[0] should be the only selected item
		var metadata = str($LoadGameScreen/GameList.get_item_metadata(items[0]))
		var gamesave_string = "user://saves/" + metadata
		SaveManager.delete_save(gamesave_string)
		$LoadGameScreen/GameList.init(SaveManager.list_saves())
