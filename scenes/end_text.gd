extends Label





func _ready() -> void:
	if Global.did_win:
		text = "U Win"
	else:
		text = "U Lose"
