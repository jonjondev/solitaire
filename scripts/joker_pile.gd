class_name JokerPile extends Pile

func is_draggable() -> bool:
	return true

func can_stack_cards(_top_card: Card, _bottom_card: Card) -> bool:
	return false

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is not Card:
		return false
	return Card.get_stacked_card(self) == null and data.rank == Card.Rank.JOKER

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.stack(self, pivot_offset - data.pivot_offset)

func add_card(card: Card) -> void:
	var top_card: Card = Card.get_top_card(self)
	if top_card:
		card.stack(top_card, get_card_stack_offset())
	else:
		card.stack(self, pivot_offset - card.pivot_offset)
