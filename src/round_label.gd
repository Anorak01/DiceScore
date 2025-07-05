extends Label


func _on_main_round_index_update(new_index: int) -> void:
	self.text = "Kolo: " + str(new_index)
