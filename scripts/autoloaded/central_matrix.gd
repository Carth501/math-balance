class_name CentralMatrix extends Node

var value_data_example := {
	"id": "example_value",
	"default_value": 10,
	"initial_value": 20,
}

var matrix := {}

func create_value(data: Dictionary) -> Value:
	var value_id = data.get("id", "unnamed_value");
	if matrix.has(value_id):
		push_warning("Value with ID '%s' already exists in CentralMatrixSingle." % value_id);
	var value = Value.new();
	add_child(value);
	value.initialize(data);
	value.name = value_id;
	matrix[value_id] = value;
	return value;

func _ready() -> void:
	create_value({
		"id": "o2",
		"default_value": 0,
		"initial_value": 200
	});

func _process(delta: float) -> void:
	## These are the processes that are updated every frame.
	process_o2(delta);

func timed_1_second_process() -> void:
	## These are the processes that are updated on a 1 second timed interval.
	pass ;

func process_o2(delta: float) -> void:
	var o2_value: Value = matrix.get("o2", null);
	if !o2_value:
		push_error("O2 value not found in CentralMatrixSingle.");
	var value_change = delta * -0.02;
	var success = o2_value.add_value(value_change);
	if !success:
		o2_value.set_value(0);