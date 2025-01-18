extends Node3D

var idx := AudioServer.get_bus_index("mic")
var spectrum := AudioServer.get_bus_effect_instance(idx, 1)
	
#func _ready() -> void:
	#
	#
	#print(typeof(spectrum))
	#
#
	#
#func _process(delta: float) -> void:
#
	#var volume: int = spectrum.get_magnitude_for_frequency_range(0, 10000).length()
	#print(volume)
