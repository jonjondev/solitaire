extends Control

const savegame_path: String = "user://game_data.ini"
const stats_scn: PackedScene = preload("res://scenes/stats.tscn")
const rules_scn: PackedScene = preload("res://scenes/rules.tscn")

const scroll_multiplier: float = 5
const pan_multiplier: float = 10
const max_scroll: float = -300

var wins_data: Array
var current_start_datetime: String

@onready var board: Board = $Board
@onready var reset_btn: Button = %ResetButton
@onready var stats_btn: Button = %StatsButton
@onready var rules_btn: Button = %RulesButton
@onready var wins_label: Label = %WinsValueLabel
@onready var popup: Control = $Popup

func _ready() -> void:
	load_game()
	board.game_won.connect(on_game_won)
	reset_btn.pressed.connect(on_reset_pressed)
	stats_btn.pressed.connect(on_stats_pressed)
	rules_btn.pressed.connect(on_rules_pressed)
	setup_game()

func on_reset_pressed():
	reset_game()

func on_stats_pressed():
	var stats = stats_scn.instantiate()
	stats.populate_wins_data(wins_data)
	popup.open(stats)

func on_rules_pressed():
	var rules = rules_scn.instantiate()
	popup.open(rules)

func reset_game():
	board.clear_board()
	await get_tree().create_timer(0.001).timeout
	setup_game()

func setup_game():
	wins_label.text = str(wins_data.size())
	board.deal_cards()
	current_start_datetime = Time.get_datetime_string_from_system()

func on_game_won():
	var end_datetime: String = Time.get_datetime_string_from_system()
	var win_entry = {"start_datetime": current_start_datetime, "end_datetime": end_datetime}
	wins_data.append(win_entry)
	save_game()
	reset_game()

func _input(event: InputEvent) -> void:
	if popup.visible:
		return
	
	var delta = 0
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				delta = -scroll_multiplier
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				delta = scroll_multiplier
	elif event is InputEventPanGesture:
		delta = event.delta.y * pan_multiplier
	
	if delta != 0:
		board.global_position.y = clamp(board.global_position.y - delta, max_scroll, 0)

func save_game():
	var config_file := ConfigFile.new()
	config_file.set_value("Game", "wins_data", wins_data)
	var error := config_file.save(savegame_path)
	if error:
		push_error("Save error: ", error)

func load_game():
	var config_file := ConfigFile.new()
	var error := config_file.load(savegame_path)
	if error:
		push_error("Load error: ", error)
		return
	wins_data = config_file.get_value("Game", "wins_data", Array())
