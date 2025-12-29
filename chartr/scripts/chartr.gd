class_name Chartr extends Control

@export var chart_area: ChartArea;
@export var margin_container: MarginContainer;
var settings: ChartrSettings = ChartrSettings.new();

## Settings will apply the next time display() is called.
## Some settings may apply the next time queue_plot() is called.
func bind_settings(new_settings: ChartrSettings) -> void:
	settings = new_settings;
	chart_area.settings = new_settings
 
## Function to display data given x and y values.
## Call again to update the display. Warning! This will overwrite previous data.
func display(x_values: Array, y_values: Array) -> void:
	if size.x < 60 or size.y < 60:
		push_warning("Chartr size is very small, and might not be displayed properly.");
		return ;
	if x_values.size() != y_values.size():
		push_warning("data size mismatch: x_values size %d, y_values size %d" % [x_values.size(), y_values.size()]);
		return ;
	if x_values.size() < 2:
		push_warning("Not enough points to plot.");
		return ;
	var y_max_and_min = get_max_and_min(y_values);
	var x_max_and_min = get_max_and_min(x_values);
	chart_area.points = generate_point_array(x_values, y_values, x_max_and_min, y_max_and_min);
	if settings.margins:
		margin_container.add_theme_constant_override("margin_left", 40)
		margin_container.add_theme_constant_override("margin_bottom", 40)
		generate_axis_labels(settings.x_axis_labels, x_max_and_min, true);
		generate_axis_labels(settings.y_axis_labels, y_max_and_min, false);
	else:
		margin_container.add_theme_constant_override("margin_left", 0)
		margin_container.add_theme_constant_override("margin_bottom", 0)
	chart_area.draw_queued = true;

## Calculates the relative positions the points will be placed at, from 0 to 1.
func generate_point_array(x_values: Array, y_values: Array, x_max_and_min: Dictionary, y_max_and_min: Dictionary) -> PackedVector2Array:
	var raw_points: PackedVector2Array = [];
	for i in range(min(x_values.size(), y_values.size())):
		raw_points.append(
			Vector2(
				(x_values[i] - x_max_and_min["min"]) / (x_max_and_min["max"] - x_max_and_min["min"]),
				(y_values[i] - y_max_and_min["min"]) / (y_max_and_min["max"] - y_max_and_min["min"])
				));
	return raw_points;

func get_max_and_min(values: Array) -> Dictionary:
	var max_value: float = - INF;
	var min_value: float = INF;
	if settings.zero_origin:
		max_value = 0;
		min_value = 0;
	for v in values:
		if v > max_value:
			max_value = v;
		if v < min_value:
			min_value = v;
	return {
		"max": max_value,
		"min": min_value,
	};

func generate_axis_labels(labels_array: Array, max_and_min: Dictionary, is_x_axis: bool) -> void:
	if labels_array.size() < 1:
		return ;
	for value in labels_array:
		if value < max_and_min["min"] or value > max_and_min["max"]:
			continue ;
		var label: Label = Label.new();
		add_child(label);
		label.text = str(value);
		var label_relative_position = ((float(value) - max_and_min["min"]) / (max_and_min["max"] - max_and_min["min"]));
		if is_x_axis:
			label.position = Vector2(
				label_relative_position * (size.x - 40) + 40 - label.size.x / 2,
				size.y - 20 - label.size.y / 2
			);
		else:
			label.position = Vector2(
				5,
				size.y - (label_relative_position * (size.y - 40) + 40) - label.size.y / 2
			);