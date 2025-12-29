class_name Chartr extends Control

var settings: ChartrSettings = ChartrSettings.new();
var points: PackedVector2Array = [];
var draw_queued: bool = false;

## Settings will apply the next time display() is called.
## Some settings may apply the next time queue_plot() is called.
func bind_settings(new_settings: ChartrSettings) -> void:
	settings = new_settings
 
## Function to display data given x and y values.
## Call again to update the display. Warning! This will overwrite previous data.
func display(x_values: Array, y_values: Array) -> void:
	if x_values.size() != y_values.size():
		push_warning("data size mismatch: x_values size %d, y_values size %d" % [x_values.size(), y_values.size()]);
		return ;
	var raw_points: PackedVector2Array = generate_point_array(x_values, y_values);

	queue_plot(raw_points);

## calculates the relative positions the points will be placed at, from 0 to 1.
func generate_point_array(x_values: Array, y_values: Array) -> PackedVector2Array:
	var y_max_and_min = get_max_and_min(y_values);
	var x_max_and_min = get_max_and_min(x_values);
	var raw_points: PackedVector2Array = [];
	for i in range(min(x_values.size(), y_values.size())):
		raw_points.append(
			Vector2(
				(x_values[i] - x_max_and_min["min"]) / x_max_and_min["max"],
				(y_values[i] - y_max_and_min["min"]) / y_max_and_min["max"]
				));
	print("Raw points generated: %s" % raw_points);
	return raw_points;

func queue_plot(new_points: PackedVector2Array) -> void:
	if new_points.size() < 2:
		push_warning("Not enough points to plot.");
		return ;
	for point in new_points:
		points.append(
			Vector2(
				point.x * size.x,
				size.y - (point.y * size.y)
			)
		);
	print("Points queued for drawing: %s" % points);
	draw_queued = true;

func _draw() -> void:
	if draw_queued:
		print("Drawing chart with %d points." % points.size());
		draw_polyline(points, Color.WHITE, 2);
		draw_queued = false;

func get_max_and_min(values: Array) -> Dictionary:
	var max_value: float = - INF;
	var min_value: float = INF;
	if settings.zero_origin:
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