extends Object
class_name Util

# Utility helper function, may want to move to static library
static func based_log(base:float = 10, x:float = 10) -> float:
	return (log(x) / log(base))
