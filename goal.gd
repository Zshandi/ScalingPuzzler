extends Area2D

signal level_complete

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Ball":
		%Timer.start()

func _on_body_exited(body: Node2D) -> void:
		if body.name == "Ball":
			%Timer.stop()

func _on_timer_timeout() -> void:
	print("You win!")
	level_complete.emit()
