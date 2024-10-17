extends Control

func set_data(data: Variant, rank: int):
	$RankLabel.text = "#%d"%rank
	var hours: int = floor(data.duration/(60*60))
	var minutes: int = floor(data.duration/(60))%60
	var seconds: int = data.duration%60
	$TimeLabel.text = "%02d:%02d:%02d"%[hours, minutes, seconds]
	var datetime: Dictionary = Time.get_datetime_dict_from_datetime_string(data.start_datetime, false)
	var hour: int = int(datetime.hour)
	var minute: int = int(datetime.minute)
	$DateLabel.text = "{day}/{month} {year} ".format(datetime) + "%02d:%02d"%[hour, minute]
