extends Label


func _on_main_player_score_label_update(new_score: int) -> void:
	self.text = "Body: " + str(new_score)
