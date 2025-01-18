extends ProgressBar


func _ready() -> void:
	value = 100
	


func _on_stammina_timer_timeout() -> void:
	value -= 1


func _on_recovery_timer_timeout() -> void:
	value += 1
