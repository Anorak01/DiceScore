extends ItemList

func init(scores: Dictionary[int, int]):
	self.clear()
	for player in scores.keys():
		self.add_item("Hráč " + str(player) + ": " + str(scores[player]))
