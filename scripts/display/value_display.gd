class_name ValueDisplay extends Node

@export var chart: Chart;
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

	chart.plot([function])

func update_chart(new_value: float) -> void:
	function.shift_forward(new_value);
	chart.queue_redraw();