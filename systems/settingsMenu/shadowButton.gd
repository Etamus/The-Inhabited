extends CheckButton

signal shadowToggled

func _on_toggled(toggled_on: bool) -> void:
	emit_signal("shadowToggled", toggled_on)
