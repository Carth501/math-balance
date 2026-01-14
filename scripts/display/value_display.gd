class_name ValueDisplay extends Node

@export var value_id: String = "o2";
@export var chart: Chartr;
@export var current_value_label: Label;
var value: Value;
var function: Function;

func _ready() -> void:
	if !CentralMatrixSingle.is_node_ready():
		await CentralMatrixSingle.ready;
		print("CentralMatrixSingle is ready, proceeding with ValueDisplay setup.");
	value = CentralMatrixSingle.matrix.get(value_id, null);
	if !value:
		push_error("%s value not found in CentralMatrixSingle." % value_id);
		return ;
	value.history_8_updated.connect(update_chart);
	value.changed.connect(func(new_value: float) -> void:
		current_value_label.text = str(new_value);
	);
	initialize_chart();

func initialize_chart() -> void:
	pass

func update_chart(_new_value: float) -> void:
	chart.display([0, 1, 2, 3, 4, 5, 6, 7], value.get_history_8s());

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
