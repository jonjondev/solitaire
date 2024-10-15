class_name TableauPile extends Pile

@export var deal_count: int = 0

func is_draggable() -> bool:
	return true

func can_stack_cards(top_card: Card, bottom_card: Card) -> bool:
	return top_card.rank == bottom_card.rank - 1 and \
		Card.get_suit_color(top_card.suit) != Card.get_suit_color(bottom_card.suit) and \
		bottom_card.rank != Card.Rank.JOKER

func get_card_stack_offset() -> Vector2:
	return Vector2(0, 50)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is not Card:
		return false
	return Card.get_stacked_card(self) == null

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	add_card(data)

func add_card(card: Card) -> void:
	var top_card: Card = Card.get_top_card(self)
	if top_card:
		card.stack(top_card, get_card_stack_offset())
	else:
		card.stack(self, pivot_offset - card.pivot_offset)
