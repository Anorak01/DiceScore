extends ItemList

func init(players: Dictionary[int, Player]):
	self.clear()
	for player in players.keys():
		self.add_item("Hráč " + str(player) + ": " + str(players[player].score))
