## A class used to represent an ok and error value.
@tool
extends RefCounted
class_name Result

## The Ok value.
var ok_value:
	set(value):
		ok_value = value
		_types.ok = Result._get_type(value)

## The Err value.
var err_value:
	set(value):
		err_value = value
		_types.err = Result._get_type(value)

var _types := {
	ok = TYPE_NIL,
	err = TYPE_NIL
}

func _init(value, _is_ok: bool) -> void:
	if _is_ok:
		ok_value = value
	else:
		err_value = value

## Form an Ok [Result] from [param value].
static func ok(value) -> Result:
	return Result.new(value, true)

## Return an Err [Result] from [param value].
static func err(value) -> Result:
	return Result.new(value, false)

## Return an Err [Result] whose value is the string form of the given
## [enum Error] code.
## [br][br]
## [color=yellow]WARNING[/color]: If [param] is not within range of the
## [enum Error] enum, the result of this function is undefined.
static func gderr(code: int) -> Result:
	# This assertion makes sure that the error code is within range (and also no OK)
	assert(code >= FAILED and code < ERR_PRINTER_ON_FIRE)
	return Result.err(error_string(code))

## Return the type of [param value].
## If [code]typeof(value)[/code] evaluates to [constant TYPE_OBJECT],
## the return value is an array containing that and the string class name
## of [param value]. Otherwise, just the [enum Variant.Type] is returned.
static func _get_type(value):
	var tp := typeof(value)
	if tp == TYPE_OBJECT:
		return [tp, (value as Object).get_class()]

# Expects

## Returns the [code]Ok[/code] value.
## If this is an [code]Err[/code] result, then the program stops with
## a custom panic message provided by [param msg].
## [codeblock]
## var does_not_fail = Result.ok("Value").expect("Does not fail")
## print(does_not_fail) # Prints "Value"
##
## var fails = Result.err("Error").expect("This fails")
## print(fails)
## [/codeblock]
func expect(msg: String):
	assert(is_ok(), "%s: %s" % [msg, err_value])
	return ok_value

## Same as [method expect] except the panic happens if this is an
## [code]Err[/code] result.
func expect_err(msg: String):
	assert(is_err(), "%s: %s" % [msg, ok_value])
	return err_value

# Predicates

# Tests whether the Result is valid.
# For it to be valid, the following conditions must be met:
# * Either ok or err is set, but not both
func _valid_result() -> bool:
	var ok_set = ok_value != null
	var err_set = err_value != null
	return (ok_set and not err_set) or (err_set and not ok_set)

func is_ok() -> bool:
	assert(_valid_result())
	return ok_value != null

func is_err() -> bool:
	assert(_valid_result())
	return err_value != null
