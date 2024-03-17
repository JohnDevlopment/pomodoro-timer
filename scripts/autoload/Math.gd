## Math singleton
extends Node

## Return the integer and fractal parts of a float.
##
## The return value is an array with the integer portion
## of [param f] and the fractal portion.
static func fract(f: float) -> Array[float]:
	return [
		float(int(f)),
		f - int(f)
	]
