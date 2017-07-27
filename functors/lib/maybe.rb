class Maybe
  def initialize(value, maybe_klass = Maybe)
    @value = value
    @maybe_klass = maybe_klass
  end

  attr_reader :value

  def map(function)
    return self if value.nil?
    return maybe_klass.new(compose(value, function)) if value.is_a?(Proc) && function.is_a?(Proc)
    # return maybe_klass.new(function).map(value) if value.is_a?(Proc) && !function.is_a?(Proc)
    maybe_klass.new(function.curry.call(value))
  end

  private

  attr_reader :maybe_klass

  def compose(f, g)
    lambda { |*args| f.call(*g.call(*args))  }
  end
end



















# ====================== EXAMPLES ======================================== #

nothing   = Maybe.new(nil)
something = Maybe.new(50)
times_two = ->(x) { x * 2}
plus_four = ->(x) { x + 4}
divide    = ->(x, y) { x / y }

# Example 1
# nil doesn't break stuff
# maintain the identity law

nothing.map(times_two)
nothing.map(times_two).map(plus_four)





















# Example 2
# it does actually do stuff
# and it's chainable

something.map(times_two)
something.map(times_two).map(plus_four)




























# Example 3
# if we don't have enough params
# function is partially applied

something.map(divide)

# we can tell because...

something.map(divide).value.call(10)

# .... And if we then map a function over that, those functions are composed (line 11)
something.map(divide).map(plus_four)
# as seen here:
something.map(divide).map(plus_four).value.call(6)




















# But there is a problem. we dont want to do ^
# Once we get a lambda inside a Maybe, how can we apply it to a value?

# We could uncomment line 12 and do this, but that feels a bit weird.
# we've got a number acting like a function, and it's unwrapped again.
# so if that value was being fed from another function that might return nil.. we back to square 1!

# something.map(divide).map(plus_four).map(6)

# What we really want to do is pass that now wrapped function to our wrapped value.
#

# Maybe.new(6).map(something.map(divide).map(plus_four))






