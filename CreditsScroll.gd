extends Label


func _process(delta: float) -> void:
	position.y -= 100 * delta
	
	var screen_height = get_viewport_rect().size.y
	
	if position.y + size.y < 0 :
		position.y = screen_height
