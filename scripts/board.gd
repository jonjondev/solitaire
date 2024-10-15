class_name Board extends Control

signal game_won

const card_scn: PackedScene = preload("res://scenes/card.tscn")

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.reset_drag()

func get_all_foundation_piles() -> Array[FoundationPile]:
	var foundation_piles: Array[FoundationPile]
	for child in get_children():
		if child is FoundationPile:
			foundation_piles.append(child)
	return foundation_piles

func get_all_tableau_piles() -> Array[TableauPile]:
	var tableau_piles: Array[TableauPile]
	for child in get_children():
		if child is TableauPile:
			tableau_piles.append(child)
	return tableau_piles

func get_joker_pile() -> JokerPile:
	for child in get_children():
		if child is JokerPile:
			return child
	return null

func get_all_tableau_cards() -> Array[Card]:
	var cards: Array[Card]
	var tableau_piles: Array[TableauPile] = get_all_tableau_piles()
	for pile in tableau_piles:
		cards.append_array(pile.get_all_stacked_cards())
	return cards

func clear_board():
	var tableau_piles: Array[TableauPile] = get_all_tableau_piles()
	for pile in tableau_piles:
		pile.clear_pile()
	var foundation_piles: Array[FoundationPile] = get_all_foundation_piles()
	for pile in foundation_piles:
		pile.clear_pile()
	var joker_pile: JokerPile = get_joker_pile()
	joker_pile.clear_pile()

func deal_cards():
	var deck: Array[Card]
	for suit in Card.Suit.values():
		if suit == Card.Suit.JOKER:
			continue
		for rank in Card.Rank.values():
			if rank == Card.Rank.JOKER:
				continue
			var card: Card = create_card(rank, suit)
			deck.append(card)
	deck.shuffle()
	
	var tableau_piles: Array[TableauPile] = get_all_tableau_piles()
	for pile in tableau_piles:
		for i in range(pile.deal_count):
			pile.add_card(deck.pop_front())
	
	if deck.size() > 0:
		push_warning("Failed to deal all gnerated cards, ", deck.size(), " cards remaining!")
	
	var joker_pile: JokerPile = get_joker_pile()
	var joker_card: Card = create_card(Card.Rank.JOKER, Card.Suit.JOKER)
	joker_pile.add_card(joker_card)

func create_card(rank: Card.Rank, suit: Card.Suit) -> Card:
	var card = card_scn.instantiate()
	card.rank = rank
	card.suit = suit
	card.card_stacked.connect(on_card_stacked)
	card.card_clicked.connect(on_card_clicked)
	return card

func on_card_stacked(_card: Card):
	if check_win_condition():
		game_won.emit()

func on_card_clicked(card: Card):
	try_bare_off(card)

func try_bare_off(card: Card):
	if not Card.is_card_movable(card) or \
		Card.get_stacked_card(card) != null or \
		card.rank == Card.Rank.JOKER:
		return
	var foundation_piles: Array[FoundationPile] = get_all_foundation_piles()
	for pile in foundation_piles:
		var top_card: Card = Card.get_top_card(pile)
		@warning_ignore("incompatible_ternary")
		var target = top_card if top_card else pile
		if target._can_drop_data(Vector2(), card):
			target._drop_data(Vector2(), card)

func check_win_condition() -> bool:
	var foundation_piles: Array[FoundationPile] = get_all_foundation_piles()
	for pile in foundation_piles:
		var top_card: Card = Card.get_top_card(pile)
		if not top_card or top_card.rank != Card.Rank.KING:
			return false
	return true
