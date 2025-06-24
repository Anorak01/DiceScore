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

var player_score: Dictionary[int, int] = {}
signal player_score_label_update(new_score: int)

var jackpot: int = 1500

func _ready() -> void:
	# set up some defaults to make dev easier
	state = STATE.START
	$StartScreen.show()
	$PlayScreen.hide()
	$ScoreScreen.hide()
	$ScoreButton.hide()

func _on_plus_button_pressed() -> void:
	player_cnt = clamp(player_cnt + 1, 2, 10)

func _on_minus_button_pressed() -> void:
	player_cnt = clamp(player_cnt - 1, 2, 10)

func _on_start_button_pressed() -> void:
	if state != STATE.START: return # what the hell
	# start the game
	state = STATE.PLAY

	# clear out scores and initialize
	player_score.clear()
	for i in range(1, player_cnt + 1):
		player_score[i] = 0

	# set player index to 1
	player_index = 1

	player_score_label_update.emit(0)

	$StartScreen.hide()
	$PlayScreen.show()
	$ScoreButton.show()

func _on_next_player_pressed() -> void:
	# change index and fire score label update
	player_index = wrap(player_index + 1, 1, player_cnt + 1)
	player_score_label_update.emit(player_score[player_index])

func _on_previous_player_pressed() -> void:
	player_index = wrap(player_index - 1, 1, player_cnt + 1)
	player_score_label_update.emit(player_score[player_index])

func score(value: int):
	if $PlayScreen/Fix.button_pressed:
		player_score[player_index] -= value
	else:
		player_score[player_index] += value
	player_score_label_update.emit(player_score[player_index])

func _on_jackpot_pressed() -> void:
	if $PlayScreen/Fix.button_pressed:
		player_score[player_index] -= jackpot
	else:
		player_score[player_index] += jackpot
	player_score_label_update.emit(player_score[player_index])


func _on_score_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$ScoreScreen/ItemList.init(player_score)
		$PlayScreen.hide()
		$ScoreScreen.show()
	else:
		$PlayScreen.show()
		$ScoreScreen.hide()


func _on_reset_button_pressed() -> void:
	state = STATE.START
	$StartScreen.show()
	$PlayScreen.hide()
	$ScoreScreen.hide()
	$ScoreButton.hide()


func _on_h_slider_value_changed(value: float) -> void:
	$StartScreen/JackpotValueLabel.text = str(int(value))
	jackpot = int(value)
