extends Control

func _ready() -> void:
	$FullScreenButton.pressed.connect(on_close_pressed)

func open(content: Control):
	%ContentContainer.add_child(content)
	visible = true

func on_close_pressed():
	for child in %ContentContainer.get_children():
		%ContentContainer.remove_child(child)
		child.queue_free()
	visible = false
