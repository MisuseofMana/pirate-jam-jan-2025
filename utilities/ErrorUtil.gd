class_name ErrorUtil

## Return the result of this method to indicate that a method must be overridden in a subclass.
static func assert_abstract():
    assert(false, "This method must be overridden in a subclass.")