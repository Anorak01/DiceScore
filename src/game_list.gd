extends ItemList

func init(saves: Dictionary[String, int]):
	self.clear()
	for save in saves.keys():
		var time: String = Time.get_time_string_from_unix_time(saves[save])
		self.add_item("Save: " + time)
		self.set_item_metadata(self.item_count-1, save)
