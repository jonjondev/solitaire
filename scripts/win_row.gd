extends Control

func set_data(data: Variant, rank: int):
	$RankLabel.text = "#%d"%rank
	var dt = Time.get_datetime_dict_from_datetime_string(data.start_datetime, false)
	var hours = floor(data.time/(60*60))
	var minutes = floor(data.time/(60))%60
	var seconds = data.time%60
	$TimeLabel.text = "%02d:%02d:%02d"%[hours, minutes, seconds]
	$DateLabel.text = "{day}/{month} {year} {hour}:{minute}".format(dt) 
