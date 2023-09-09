extends Area2D


func _on_DeathTrigger_body_entered(body):
	if body.is_in_group("Player"):
		body.set_state(1) # should be FALL state in player
