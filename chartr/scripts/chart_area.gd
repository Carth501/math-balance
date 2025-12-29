class_name ChartArea extends Control

var settings: ChartrSettings = ChartrSettings.new();
var points: PackedVector2Array = [];
var draw_queued: bool = false;

func _draw() -> void:
	if !draw_queued:
		return ;
	var scaled_points: PackedVector2Array = [];
	for point in points:
		scaled_points.append(
			Vector2(
				point.x * size.x,
				size.y - (point.y * size.y)
			)
		);
	draw_polyline(scaled_points, Color.WHITE, 4);
	draw_queued = false;
	if settings.shading:
		var shading_points: PackedVector2Array = scaled_points.duplicate();
		shading_points.append(Vector2(scaled_points[scaled_points.size() - 1].x, size.y));
		shading_points.append(Vector2(scaled_points[0].x, size.y));
		draw_colored_polygon(shading_points, settings.shading_color, [], null);
	if settings.grid_lines:
		for point in scaled_points:
			draw_line(Vector2(point.x, 0), Vector2(point.x, size.y), Color(0.5, 0.5, 0.5, 0.3), 2);

func _resized() -> void:
	draw_queued = true;
