class_name ChartrSettings extends RefCounted

## If true, the origin will be included in the chart area.
var zero_origin: bool = true;
## If true, the area between the line and the x-axis will be shaded.
var shading: bool = true;
## The color used for shading the area under the line.
var shading_color: Color = Color(0, 0, 0, 1);
## If true, vertical grid lines will be drawn at each data point.
var grid_lines: bool = true;
## If true, margins will be added around the chart area for the axes' labels.
var margins: bool = true;
## Labels for the x axis. Leave empty for automatic labeling.
var x_axis_labels: Array = [];
## Labels for the y axis. Leave empty for automatic labeling.
var y_axis_labels: Array = [];