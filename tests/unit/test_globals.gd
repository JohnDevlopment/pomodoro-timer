extends GutTest

var params_time_to_seconds = \
	ParameterFactory.named_parameters(["h", "m", "s", "expected"], [
		[1, 0, 0, 3600],
		[0, 1, 30, 90],
	])

var params_seconds_to_time = \
	ParameterFactory.named_parameters(["seconds", "eh", "em", "es"], [
		# 00:15:00
		[900, 0, 15, 0.0],
		# 01:00:00
		[3600, 1, 0, 0.0],
		# 00:01:30
		[90, 0, 1, 30.0],
	])

func test_time_to_seconds(params=use_parameters(params_time_to_seconds)) -> void:
	var seconds := Globals.time_to_seconds({
		hours = params.h,
		minutes = params.m,
		seconds = params.s,
	})
	assert_eq(seconds, params.expected)

func test_seconds_to_time__type():
	var time := Globals.seconds_to_time(90)
	assert_typeof(time, TYPE_DICTIONARY)
	assert_eq(time.hours, 0)
	assert_eq(time.minutes, 1)
	assert_almost_eq(time.seconds, 30.0, 0.01)

func test_seconds_to_time(params=use_parameters(params_seconds_to_time)) -> void:
	var time := Globals.seconds_to_time(params.seconds)
	assert_eq(time.hours, params.eh)
	assert_eq(time.minutes, params.em)
	assert_almost_eq(time.seconds, params.es, 0.1)
