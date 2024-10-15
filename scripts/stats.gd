extends Control

func populate_wins_data(wins_data: Array):
	$HBoxContainer/WinsValueLabel.text = str(wins_data.size())
	
	for data in wins_data:
		var start = Time.get_unix_time_from_datetime_string(data.start_datetime)
		var end = Time.get_unix_time_from_datetime_string(data.end_datetime)
		data["time"] = end - start
	
	for child in %WinsRows.get_children():
		child.queue_free()
	
	wins_data.sort_custom(func(a, b): return a.time < b.time)
	
	for i in range(wins_data.size()):
		var data = wins_data[i]
		var win_row = preload("res://scenes/win_row.tscn").instantiate()
		win_row.set_data(data, i+1)
		%WinsRows.add_child(win_row)
