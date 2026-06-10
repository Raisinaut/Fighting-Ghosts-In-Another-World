extends Area2D


# sums normalized vectors pointing from overlapping bodies
func get_push_vector() -> Vector2:
	var push_vector = Vector2.ZERO
	var bodies = get_overlapping_bodies()
#	print(bodies)
	if not bodies.empty():
		push_vector += bodies[0].global_position.direction_to(self.global_position)
		for b in bodies:
			push_vector += b.global_position.direction_to(self.global_position)
#	print(push_vector)
	return push_vector
