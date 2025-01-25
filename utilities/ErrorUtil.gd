class_name ErrorUtil

# Assertion utilities to silence return type warnings in invalid code paths

## Return the result of this method to indicate that a method must be overridden in a subclass.
static func assert_abstract():
	assert(false, "This method must be overridden in a subclass.")

## Return the result of this method to indicate that a code path should be unreachable.
static func assert_unreachable():
	assert(false, "This code path should be unreachable.")