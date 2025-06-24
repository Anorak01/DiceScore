extends Label

func _on_main_player_cnt_update(new_cnt: int) -> void:
	self.text = str(new_cnt)
