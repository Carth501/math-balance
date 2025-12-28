## This is a generic value object. More specific types can inherit from this.
class_name Value extends Node

signal changed(new_value);
signal history_8_updated(new_value);
signal history_64_updated(new_value);
signal history_512_updated(new_value);

var default_value := 0;
var value := 0;
## Stores the snapshot value for each of the last 8 seconds.
# 2^3
var history_8s: Array = [];
## Stores the 8-second rolling average value of the last 64 seconds.
# 2^6
var history_64s: Array = [];
## Stores the 64-second double-rolling average value of the last 512 seconds.
# 2^9
var history_512s: Array = [];

func _ready() -> void:
	var timer_1 = Timer.new();
	timer_1.wait_time = 1.0;
	timer_1.one_shot = false;
	add_child(timer_1);
	timer_1.timeout.connect(_on_timer_1_timeout);
	timer_1.start();

	var timer_2 = Timer.new();
	timer_2.wait_time = 8.0;
	timer_2.one_shot = false;
	add_child(timer_2);
	timer_2.timeout.connect(_on_timer_2_timeout);
	timer_2.start();

	var timer_3 = Timer.new();
	timer_3.wait_time = 64.0;
	timer_3.one_shot = false;
	add_child(timer_3);
	timer_3.timeout.connect(_on_timer_3_timeout);
	timer_3.start();


func set_value(new_value):
	if value != new_value:
		value = new_value;
		emit_signal("changed", new_value);

func get_value():
	return value;

func add_value(amount) -> bool:
	if value + amount < 0:
		return false;
	set_value(value + amount);
	return true;

func multiply_value(factor):
	set_value(value * factor);

func exponentiate_value(power):
	set_value(pow(value, power));

func reset_value():
	set_value(default_value);

func initialize(data: Dictionary) -> void:
	if data.has("default_value"):
		default_value = data["default_value"];
	else:
		default_value = 0;

	if data.has("initial_value"):
		set_value(data["initial_value"]);
	else:
		reset_value();

func _on_timer_1_timeout() -> void:
	history_8s.push_front(value);
	if history_8s.size() > 8:
		history_8s.pop_back();
	history_8_updated.emit(value);

func get_history_8s() -> Array:
	var copy := history_8s.duplicate();
	if copy.size() < 8:
		for i in range(8 - copy.size()):
			copy.append(0);
	return copy;

func _on_timer_2_timeout() -> void:
	var sum := 0;
	for v in history_8s:
		sum += v;
	var average = sum / max(history_8s.size(), 1);
	history_64s.push_front(average);
	if history_64s.size() > 8:
		history_64s.pop_back();
	history_64_updated.emit(average);

func get_history_64s() -> Array:
	return history_64s.duplicate();

func _on_timer_3_timeout() -> void:
	var sum := 0;
	for v in history_64s:
		sum += v;
	var average = sum / max(history_64s.size(), 1);
	history_512s.push_front(average);
	if history_512s.size() > 8:
		history_512s.pop_back();
	history_512_updated.emit(average);

func get_history_512s() -> Array:
	return history_512s.duplicate();