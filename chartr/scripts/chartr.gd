class_name Chartr extends Control

@export var settings: ChartrSettings;
var raw_data: Dictionary;
var percent_points: PackedVector2Array;
var draw_queued: bool = false;
var chart_area_top_left: Vector2 = Vector2.ZERO;
var chart_area_bottom_right: Vector2 = Vector2.ZERO;
var x_axis_labels_nodes: Dictionary = {};
var y_axis_labels_nodes: Dictionary = {};
var max_and_min: Dictionary;
var polyline: Line2D;

## Settings will apply the next time display() is called.
## Some settings may apply the next time queue_plot() is called.
func bind_settings(new_settings: ChartrSettings) -> void:
	settings = new_settings;
 
## Function to display data given x and y values.
## Call again to update the display. Warning! This will overwrite previous data.
func display(data: Dictionary) -> void:
	for key in data:
		if float(key) == null:
			push_warning("x_values must be numeric.");
		if float(data[key]) == null:
			push_warning("y_values must be numeric.");
	raw_data = data;
	if polyline == null:
		polyline = Line2D.new();
		add_child(polyline);
	else:
		polyline.clear_points();
	if size.x < 60 or size.y < 60:
		push_warning("Chartr size is very small, and might not be displayed properly.");
		return ;
	max_and_min = get_max_and_min(raw_data);
	percent_points = generate_point_array(raw_data);
	var scaled_points := calculate_point_array(percent_points);
	for point in scaled_points:
		polyline.add_point(point);
	chart_area_top_left = Vector2(0, 0);
	chart_area_bottom_right = size;

## Calculates the relative positions the points will be placed at, from 0 to 1.
func generate_point_array(data: Dictionary) -> PackedVector2Array:
	var scaled_points: PackedVector2Array = [];
	if (max_and_min["max"] - max_and_min["min"]) == Vector2.ZERO:
		push_error("All x values are identical; cannot generate chart.");
	var divisor = (max_and_min["max"] - max_and_min["min"]);
	for x in data:
		var point = Vector2(x, data[x]);
		scaled_points.append(
			(point - max_and_min["min"]) / divisor
		);
	return scaled_points;

func get_max_and_min(data: Dictionary) -> Dictionary:
	var max_value: Vector2 = Vector2(-INF, -INF);
	var min_value: Vector2 = Vector2(INF, INF);
	if settings.zero_origin:
		max_value = Vector2(0, 0);
		min_value = Vector2(0, 0);
	for x in data:
		if x > max_value.x:
			max_value.x = x;
		if x < min_value.x:
			min_value.x = x;
		var y = data[x];
		if y > max_value.y:
			max_value.y = y;
		if y < min_value.y:
			min_value.y = y;
	if max_value.x == -INF || max_value.y == -INF:
		push_error("Cannot determine max values for chart. Data: ", data);
	if min_value.x == INF || min_value.y == INF:
		push_error("Cannot determine max values for chart. Data: ", data);
	return {
		"max": max_value,
		"min": min_value,
	};

func calculate_point_array(points: PackedVector2Array) -> PackedVector2Array:
	var scaled_points: PackedVector2Array = [];
	for point in points:
		var scaled_point = Vector2(
			get_x(point.x),
			get_y(point.y)
		);
		scaled_points.append(scaled_point);
	return scaled_points;


func _resized() -> void:
	pass ;

func get_y(y_value: float) -> float:
	var bottom_border: float = chart_area_bottom_right.y;
	var padding: float = settings.padding.y * (chart_area_bottom_right.y - chart_area_top_left.y);
	return bottom_border - padding - (y_value * (chart_area_bottom_right.y - chart_area_top_left.y - (2 * padding)));

func get_x(x_value: float) -> float:
	var left_border: float = chart_area_top_left.x;
	var padding: float = settings.padding.x * (chart_area_bottom_right.x - left_border);
	left_border += padding;
	return left_border + x_value * (chart_area_bottom_right.x - left_border - padding);

func round_to_factor(value: float, factor: float) -> float:
	return round(value / factor) * factor;
