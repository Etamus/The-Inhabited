extends CheckButton

signal fogToggle

func _on_toggled(toggled_on: bool) -> void:
	emit_signal("fogToggle", toggled_on)
