class_name Chartr extends Control

var settings: ChartrSettings = ChartrSettings.new();
var points: PackedVector2Array = [];
var draw_queued: bool = false;
var chart_area_top_left: Vector2 = Vector2.ZERO;
var chart_area_bottom_right: Vector2 = Vector2.ZERO;
var x_axis_labels_nodes: Array = [];
var y_axis_labels_nodes: Array = [];
var y_max_and_min: Dictionary;
var x_max_and_min: Dictionary;

## Settings will apply the next time display() is called.
## Some settings may apply the next time queue_plot() is called.
func bind_settings(new_settings: ChartrSettings) -> void:
	settings = new_settings;
 
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
	y_max_and_min = get_max_and_min(y_values);
	x_max_and_min = get_max_and_min(x_values);
	points = generate_point_array(x_values, y_values);
	if settings.margins:
		chart_area_top_left = Vector2(40, 0);
		chart_area_bottom_right = Vector2(size.x, size.y - 40);
		generate_axis_labels(settings.x_axis_labels, x_max_and_min, true);
		generate_axis_labels(settings.y_axis_labels, y_max_and_min, false);
		place_axis_labels();
	else:
		chart_area_top_left = Vector2(0, 0);
		chart_area_bottom_right = size;
	draw_queued = true;

## Calculates the relative positions the points will be placed at, from 0 to 1.
func generate_point_array(x_values: Array, y_values: Array) -> PackedVector2Array:
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
		if is_x_axis:
			x_axis_labels_nodes.append(label);
		else:
			y_axis_labels_nodes.append(label);
	
func place_axis_labels() -> void:
	if x_max_and_min == null or y_max_and_min == null:
		return ;
	if !x_max_and_min.has("min") or !x_max_and_min.has("max"):
		return ;
	if !y_max_and_min.has("min") or !y_max_and_min.has("max"):
		return ;
	for label in x_axis_labels_nodes:
		var value: float = float(label.text);
		var label_relative_position = ((float(value) - x_max_and_min["min"]) / (x_max_and_min["max"] - x_max_and_min["min"]));
		label.position = Vector2(
			get_x(label_relative_position) - label.size.x / 2,
			size.y - 20 - label.size.y / 2
		);
	for label in y_axis_labels_nodes:
		var value: float = float(label.text);
		var label_relative_position = ((float(value) - y_max_and_min["min"]) / (y_max_and_min["max"] - y_max_and_min["min"]));
		label.position = Vector2(
			5,
			get_y(label_relative_position) - label.size.y / 2
		);

func _draw() -> void:
	if !draw_queued:
		return ;
	var scaled_points: PackedVector2Array = [];
	for point in points:
		scaled_points.append(
			Vector2(
				get_x(point.x),
				get_y(point.y)
			)
		);
	draw_polyline(scaled_points, Color.WHITE, 4);
	if settings.shading:
		var shading_points: PackedVector2Array = scaled_points.duplicate();
		var origin_y: float = get_y(0);
		shading_points.append(Vector2(scaled_points[scaled_points.size() - 1].x, origin_y));
		shading_points.append(Vector2(scaled_points[0].x, origin_y));
		draw_colored_polygon(shading_points, settings.shading_color, [], null);
	if settings.grid_lines:
		for point in scaled_points:
			draw_line(Vector2(point.x, 0), Vector2(point.x, chart_area_bottom_right.y), Color(0.5, 0.5, 0.5, 0.3), 2);
		if y_max_and_min["max"] >= 0 and y_max_and_min["min"] <= 0 or settings.zero_origin:
			var zero_y: float = get_y(0);
			draw_line(Vector2(chart_area_top_left.x, zero_y), Vector2(chart_area_bottom_right.x, zero_y), Color(0.5, 0.5, 0.5, 0.3), 2);
		if x_max_and_min["max"] >= 0 and x_max_and_min["min"] <= 0 or settings.zero_origin:
			var zero_x: float = get_x(0);
			draw_line(Vector2(zero_x, chart_area_top_left.y), Vector2(zero_x, chart_area_bottom_right.y), Color(0.5, 0.5, 0.5, 0.3), 2);
	draw_queued = false;

func _resized() -> void:
	if settings.margins:
		chart_area_top_left = Vector2(40, 0);
		chart_area_bottom_right = Vector2(size.x, size.y - 40);
	else:
		chart_area_top_left = Vector2(0, 0);
		chart_area_bottom_right = size;
	place_axis_labels();
	draw_queued = true;

func get_y(y_value: float) -> float:
	var bottom_border: float = chart_area_bottom_right.y;
	var padding: float = settings.padding.y * (chart_area_bottom_right.y - chart_area_top_left.y);
	return bottom_border - padding - (y_value * (chart_area_bottom_right.y - chart_area_top_left.y - (2 * padding)));

func get_x(x_value: float) -> float:
	var left_border: float = chart_area_top_left.x;
	var padding: float = settings.padding.x * (chart_area_bottom_right.x - left_border);
	left_border += padding;
	return left_border + x_value * (chart_area_bottom_right.x - left_border - padding);