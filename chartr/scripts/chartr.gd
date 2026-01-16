class_name Chartr extends Control

@export var settings: ChartrSettings;
var raw_data: Dictionary;
var percent_points: PackedVector2Array;
var draw_queued: bool = false;
var chart_area_top_left: Vector2 = Vector2.ZERO;
var chart_area_bottom_right: Vector2 = Vector2.ZERO;
var max_and_min: Dictionary;
var polyline: Line2D;
var grid_line_nodes: Dictionary = {};

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
	if settings.margins:
		chart_area_top_left = Vector2(60, 0);
		chart_area_bottom_right = size - Vector2(0, 40);
		draw_grid_lines();
	else:
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
			get_x_on_chart(point.x),
			get_y_on_chart(point.y)
		);
		scaled_points.append(scaled_point);
	return scaled_points;


func _resized() -> void:
	pass ;

func get_y_on_chart(y_value: float) -> float:
	var bottom_border: float = chart_area_bottom_right.y;
	var padding: float = settings.padding.y * (chart_area_bottom_right.y - chart_area_top_left.y);
	return bottom_border - padding - (y_value * (chart_area_bottom_right.y - chart_area_top_left.y - (2 * padding)));

func get_x_on_chart(x_value: float) -> float:
	var left_border: float = chart_area_top_left.x;
	var padding: float = settings.padding.x * (chart_area_bottom_right.x - left_border);
	left_border += padding;
	return left_border + x_value * (chart_area_bottom_right.x - left_border - padding);

func round_to_factor(value: float, factor: float) -> float:
	return round(value / factor) * factor;

func draw_grid_lines() -> void:
	clear_grid_lines();
	draw_x_grid_lines();
	draw_y_grid_lines();

func draw_x_grid_lines() -> void:
	if !settings.grid_lines:
		return ;
	var x_range: float = max_and_min["max"].x - max_and_min["min"].x;
	var approx_lines: int = 10;
	var raw_interval: float = x_range / approx_lines;
	grid_line_nodes["x"] = {};
	for count in range(approx_lines + 1):
		var x_value: float = max_and_min["min"].x + (count * raw_interval);
		var percent_x: float = (x_value - max_and_min["min"].x) / x_range;
		var chart_x: float = get_x_on_chart(percent_x);
		var grid_line_node: Line2D = Line2D.new();
		grid_line_node.width = 1.0;
		grid_line_node.default_color = Color(0.7, 0.7, 0.7, 0.5);
		grid_line_node.add_point(Vector2(chart_x, chart_area_top_left.y));
		grid_line_node.add_point(Vector2(chart_x, chart_area_bottom_right.y));
		add_child(grid_line_node);
		var grid_line_label_node = Label.new();
		add_child(grid_line_label_node);
		grid_line_label_node.set_text(str(round_to_factor(x_value, 0.1)));
		var offset = (grid_line_label_node.size);
		grid_line_label_node.position = Vector2(chart_x - (offset.x * 2), chart_area_bottom_right.y + 20);
		grid_line_nodes["x"][x_value] = {"line": grid_line_node, "label": grid_line_label_node};

func draw_y_grid_lines() -> void:
	if !settings.grid_lines:
		return ;
	var y_range: float = max_and_min["max"].y - max_and_min["min"].y;
	var approx_lines: int = 10;
	var raw_interval: float = y_range / approx_lines;
	grid_line_nodes["y"] = {};
	for count in range(approx_lines + 1):
		var y_value: float = max_and_min["min"].y + (count * raw_interval);
		var percent_y: float = (y_value - max_and_min["min"].y) / y_range;
		var chart_y: float = get_y_on_chart(percent_y);
		var grid_line_node: Line2D = Line2D.new();
		grid_line_node.width = 1.0;
		grid_line_node.default_color = Color(0.7, 0.7, 0.7, 0.5);
		grid_line_node.add_point(Vector2(chart_area_top_left.x, chart_y));
		grid_line_node.add_point(Vector2(chart_area_bottom_right.x, chart_y));
		add_child(grid_line_node);
		var grid_line_label_node = Label.new();
		add_child(grid_line_label_node);
		grid_line_label_node.set_text(str(round_to_factor(y_value, 0.1)));
		var offset = (grid_line_label_node.size);
		grid_line_label_node.position = Vector2(8, chart_y - (offset.y / 2));
		grid_line_nodes["y"][y_value] = {"line": grid_line_node, "label": grid_line_label_node};

func clear_grid_lines() -> void:
	for axis_key in grid_line_nodes:
		for grid_line_key in grid_line_nodes[axis_key]:
			var grid_line_node: Line2D = grid_line_nodes[axis_key][grid_line_key]["line"];
			remove_child(grid_line_node);
			grid_line_node.queue_free();
			var grid_line_label_node: Label = grid_line_nodes[axis_key][grid_line_key]["label"];
			remove_child(grid_line_label_node);
			grid_line_label_node.queue_free();
	grid_line_nodes.clear();