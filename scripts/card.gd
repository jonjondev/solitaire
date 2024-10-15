class_name Card extends Control

enum Suit {
	SPADES,
	CLUBS,
	HEARTS,
	DIAMONDS,
	JOKER
}

enum Rank {
	ACE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING,
	JOKER
}

static func get_suit_color(card_suit: Suit):
	match card_suit:
		Suit.SPADES, Suit.CLUBS:
			return Color.BLACK
		Suit.HEARTS, Suit.DIAMONDS:
			return Color.RED
		Suit.JOKER:
			return Color.DARK_GREEN

static func get_suit_text(card_suit: Suit):
	match card_suit:
		Suit.SPADES:
			return "♠"
		Suit.CLUBS:
			return "♣"
		Suit.HEARTS:
			return "♥"
		Suit.DIAMONDS:
			return "♦"
		Suit.JOKER:
			return ""

static func get_rank_text(card_rank: Rank):
	match card_rank:
		Rank.ACE:
			return "A"
		Rank.JACK:
			return "J"
		Rank.QUEEN:
			return "Q"
		Rank.KING:
			return "K"
		Rank.JOKER:
			return "JOKER"
		_:
			return str(card_rank + 1)

static func get_stacked_card(node: Node) -> Card:
	for child in node.get_children():
		if child is Card:
			return child
	return null

static func get_top_card(node: Node) -> Card:
	var card: Card = null
	var next_card: Card = node if node is Card else Card.get_stacked_card(node)
	while next_card != null:
		card = next_card
		next_card = Card.get_stacked_card(card)
	return card

static func is_card_movable(card: Card) -> bool:
	var pile: Pile = get_root_pile(card)
	if pile == null:
		return true
	var next_card: Card = Card.get_stacked_card(card)
	while next_card != null:
		if not pile.can_stack_cards(next_card, card):
			return false
		card = next_card
		next_card = Card.get_stacked_card(card)
	return true

static func get_root_pile(node: Node) -> Pile:
	while node != null:
		node = node.get_parent()
		if node is Pile:
			return node
	return null

signal card_stacked(card: Card)
signal card_clicked(card: Card)

@export var rank: Rank
@export var suit: Suit

var in_click = false
var mouse_over = false

var dragging = false:
	set(new_dragging):
		dragging = new_dragging
		mouse_filter = MOUSE_FILTER_IGNORE if dragging else MOUSE_FILTER_STOP
		z_index = 100 if dragging else 0

@onready var reset_pos: Vector2 = global_position
@onready var reset_z: int = z_index
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_entered.connect(func(): mouse_over = true)
	mouse_exited.connect(func(): mouse_over = false)
	update_visuals()

func update_visuals():
	$TopVbox/RankLabel.text = get_rank_text(rank)
	$BottomVbox/RankLabel.text = get_rank_text(rank)
	$BottomVbox/SuitLabel.text = get_suit_text(suit)
	$TopVbox/SuitLabel.text = get_suit_text(suit)
	var color = get_suit_color(suit)
	$BottomVbox/SuitLabel.add_theme_color_override("font_color", color)
	$TopVbox/SuitLabel.add_theme_color_override("font_color", color)
	$TopVbox/RankLabel.add_theme_color_override("font_color", color)
	$BottomVbox/RankLabel.add_theme_color_override("font_color", color)

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_viewport().get_mouse_position() + drag_offset

func _input(event: InputEvent) -> void:
	if not dragging:
		if event.is_action_pressed("mouse_down") and mouse_over:
			in_click = true
		elif event.is_action_released("mouse_down") and mouse_over and in_click:
			in_click = false
			card_clicked.emit(self)
		return
	if event.is_action_released("mouse_down"):
		reset_drag()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not is_card_movable(self):
		return null
	var pile: Pile = get_root_pile(self)
	if pile and not pile.is_draggable():
		return null
	start_drag()
	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is not Card:
		return false
	if data.rank == Rank.JOKER:
		return true
	if get_stacked_card(self):
		return false
	var pile: Pile = get_root_pile(self)
	if not pile:
		return false
	return pile.can_stack_cards(data, self)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data.rank == Rank.JOKER:
		data.rank = rank
		data.suit = suit
		rank = Rank.JOKER
		suit = Suit.JOKER
		update_visuals()
		data.update_visuals()
		card_stacked.emit(self)
	else:
		var pile: Pile = get_root_pile(self)
		var stack_offset = pile.get_card_stack_offset() if pile else Vector2(0, 50)
		data.stack(self, stack_offset)

func start_drag():
	reset_pos = global_position
	reset_z = z_index
	drag_offset = global_position - get_viewport().get_mouse_position()
	dragging = true

func stack(parent: Node, offset: Vector2):
	if get_parent():
		reparent(parent, true)
	else:
		parent.add_child(self)
	end_drag(parent.global_position + offset, parent.z_index + 1)
	card_stacked.emit(self)

func end_drag(pos: Vector2, z: int):
	global_position = pos
	in_click = false
	dragging = false
	z_index = z

func reset_drag():
	end_drag(reset_pos, reset_z)
