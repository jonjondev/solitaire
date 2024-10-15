class_name FoundationPile extends Pile

func can_stack_cards(top_card: Card, bottom_card: Card) -> bool:
	return top_card.rank == bottom_card.rank + 1 and \
		top_card.suit == bottom_card.suit and \
		top_card.rank != Card.Rank.JOKER

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is not Card:
		return false
	return Card.get_stacked_card(self) == null and data.rank == Card.Rank.ACE

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.stack(self, pivot_offset - data.pivot_offset)
