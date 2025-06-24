extends Label


func _on_main_player_index_update(new_index: int) -> void:
	self.text = "Hráč " + str(new_index)
