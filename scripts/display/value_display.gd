class_name ValueDisplay extends Node

@export var chart: Chart;
@export var current_value_label: Label;
var value: Value;
var function: Function;

func _ready() -> void:
	if !CentralMatrixSingle.is_node_ready():
		await CentralMatrixSingle.ready;
		print("CentralMatrixSingle is ready, proceeding with ValueDisplay setup.");
	value = CentralMatrixSingle.matrix.get("o2", null);
	if !value:
		push_error("O2 value not found in CentralMatrixSingle.");
		return ;
	value.history_8_updated.connect(update_chart);
	value.changed.connect(func(new_value: float) -> void:
		current_value_label.text = str(new_value);
	);
	initialize_chart();

func initialize_chart() -> void:
	function = Function.new(
		[0, 1, 2, 3, 4, 5, 6, 7],
		value.get_history_8s(),
		"First function",
		{
			type = Function.Type.LINE,
			marker = Function.Marker.SQUARE,
			color = Color("#36a2eb"),
		}
	)
	var chart_properties: ChartProperties = ChartProperties.new();
	chart_properties.x_scale = 7;

	chart.plot([function], chart_properties);

func update_chart(new_value: float) -> void:
	function.shift_forward(new_value);
	chart.queue_redraw();

func _on_reset_button_pressed() -> void:
	value.reset_value();

func _on_mass_subtract_button_pressed() -> void:
	value.add_value(-10);

func _on_subtract_button_pressed() -> void:
	value.add_value(-1);

func _on_add_button_pressed() -> void:
	value.add_value(1);

func _on_mass_add_button_pressed() -> void:
	value.add_value(10);
