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
	create_value({
		"id": "o2_generator",
		"default_value": 0,
		"initial_value": 0.152
	});
	create_value({
		"id": "o2_generator_degradation",
		"default_value": 0,
		"initial_value": 0.0001
	});

func _process(delta: float) -> void:
	## These are the processes that are updated every frame.
	process_o2(delta);
	process_o2_generator(delta);

func timed_1_second_process() -> void:
	## These are the processes that are updated on a 1 second timed interval.
	pass ;

func process_o2(delta: float) -> void:
	var o2_value: Value = matrix.get("o2", null);
	if !o2_value:
		push_error("O2 value not found in CentralMatrixSingle.");
	var value_change = delta * -0.1825;
	var success = o2_value.add_value(value_change);
	if !success:
		o2_value.set_value(0);

func process_o2_generator(delta: float) -> void:
	var o2_value: Value = matrix.get("o2", null);
	var o2_generator_value: Value = matrix.get("o2_generator", null);
	var o2_generator_degradation_value: Value = matrix.get("o2_generator_degradation", null);
	if !o2_value:
		push_error("O2 value not found in CentralMatrixSingle.");
	if !o2_generator_value:
		push_error("O2 Generator value not found in CentralMatrixSingle.");
	if !o2_generator_degradation_value:
		push_error("O2 Generator Degradation value not found in CentralMatrixSingle.");
	var generated_o2 = delta * o2_generator_value.get_value();
	o2_value.add_value(generated_o2);
	var degradation_amount = delta * o2_generator_degradation_value.get_value();
	o2_generator_value.add_value(-degradation_amount);
	if o2_generator_value.get_value() < 0:
		o2_generator_value.set_value(0);