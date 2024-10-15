class_name Pile extends Control

func is_draggable() -> bool:
	return false

func can_stack_cards(_top_card: Card, _bottom_card: Card) -> bool:
	return false

func get_card_stack_offset() -> Vector2:
	return Vector2.ZERO

func get_all_stacked_cards() -> Array[Card]:
	var cards: Array[Card]
	var current_card: Card = Card.get_stacked_card(self)
	while current_card != null:
		cards.append(current_card)
		current_card = Card.get_stacked_card(current_card)
	return cards

func clear_pile() -> void:
	for card in get_all_stacked_cards():
		card.queue_free()

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return false

func _drop_data(_at_position: Vector2, _data: Variant) -> void:
	pass
