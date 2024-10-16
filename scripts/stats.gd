class_name Stats extends Control

const win_row_scn: PackedScene = preload("res://scenes/win_row.tscn")
const achievement_scn: PackedScene = preload("res://scenes/achievement.tscn")

static func get_duration_between_datetime_strings(start: String, end: String) -> int:
	var start_time: int = Time.get_unix_time_from_datetime_string(start)
	var end_time: int = Time.get_unix_time_from_datetime_string(end)
	return end_time - start_time

var achievements: Dictionary = {
	"Quickly!;Win a game in under two minutes.;Pick up the pace...": func(wins_data: Array):
		for data in wins_data:
			var duration: int = get_duration_between_datetime_strings(data.start_datetime, data.end_datetime)
			if duration < 120:
				return true
		return false,
	"Marry Me!;Win 100 games.;Keep playing...": func(wins_data: Array):
		return wins_data.size() >= 100,
	"You Fool!;Win a game without using the joker.;Do it the hard way...": func(wins_data: Array):
		for data in wins_data:
			if not data.used_joker:
				return true
		return false,
}

func populate_wins_data(wins_data: Array):
	%WinsValueLabel.text = str(wins_data.size())
	
	for achievement in achievements:
		var node: Control = achievement_scn.instantiate()
		var achievement_text = achievement.split(";", false)
		if achievements[achievement].call(wins_data):
			node.text = achievement_text[0]
			node.tooltip_text = achievement_text[1]
			%AchievementsContainer.add_child(node)
		else:
			node.text = "Locked"
			node.tooltip_text = achievement_text[2]
			%AchievementsContainer.add_child(node)
	
	for child in %WinsRows.get_children():
		child.queue_free()
	
	for data in wins_data:
		data["duration"] = get_duration_between_datetime_strings(data.start_datetime, data.end_datetime)
	
	wins_data.sort_custom(func(a, b): return a.duration < b.duration)
	
	for i in range(wins_data.size()):
		var data = wins_data[i]
		var win_row: Control = win_row_scn.instantiate()
		win_row.set_data(data, i+1)
		%WinsRows.add_child(win_row)
