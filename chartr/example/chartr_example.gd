extends Control

@export var chart: Chartr;

func _ready() -> void:
	var settings: ChartrSettings = ChartrSettings.new();
	settings.zero_origin = false;
	settings.x_axis_labels = [0, 2, 4, 6];
	chart.bind_settings(settings);
	chart.display(
		[0, 1, 2, 3, 4, 5, 6, 7],
		[10, 12, 8, 15, 14, 20, 18, 25]
		);