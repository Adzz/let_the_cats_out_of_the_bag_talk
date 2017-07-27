class Maybe
  def initialize(value, maybe_klass = Maybe)
    @value = value
    @maybe_klass = maybe_klass
  end

  attr_reader :value

  def map(function)
    return self if value.nil?
    return maybe_klass.new(compose(value, function)) if value.is_a?(Proc) && function.is_a?(Proc)
    return maybe_klass.new(function).map(value) if value.is_a?(Proc) && !function.is_a?(Proc)
    maybe_klass.new(function.curry.call(value))
  end

  def apply(maybe_function)
    return self if maybe_function.value.nil?
    map(maybe_function.value)
  end

  private

  attr_reader :maybe_klass

  def flatten_result(result)
    if result.value.is_a? Maybe
      return result.value
    else
      return result
    end
  end

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end

# ====================== EXAMPLES ======================================== #

nothing             = Maybe.new(nil)
something           = Maybe.new(50)
times_two           = ->(x) { x * 2}
plus_four           = ->(x) { x + 4}
times_two_plus_four = ->(x) { (x * 2) + 4}
divide              = ->(x, y) { x / y }

# Applicative laws: 1. Identity
# we get the same answer as if we mapped an unwrapped function over the functor
# (in the fp sense, not the object identity sense. Pointer in mem is different)
#  but the value is the same)

something.map(times_two)
# is the same as:
something.apply(Maybe.new(times_two))

# Next Law is that it's still associative
# in this sense:

something.apply(Maybe.new(times_two)).apply(Maybe.new(plus_four))
# is the same as:
something.apply(Maybe.new(times_two_plus_four))


# But there is a stumbling block...
# What if the function we are applying RETURNS A WRAPPED MAYBE?

stumbling_block = -> (x){ Maybe.new(x + 1) }

# this works okay, we get a nested maybe
Maybe.new(5).apply(Maybe.new(stumbling_block))

# but what if we try to chain that?
Maybe.new(5).bind(Maybe.new(stumbling_block)).apply(Maybe.new(stumbling_block))

# Oh no. :(
# so we need something else....


# =============================== AN ASIDE ===================================================#

class Array
  def apply(array_of_functions)
    return self if self.empty?
    return self if array_of_functions.empty?
    self.flat_map do |element|
      array_of_functions.map do |func|
        if element.is_a? Proc
          compose(element, func)
        else
          func.curry.call(element)
        end
      end
    end
  end

  def zip_apply(array_of_functions)
    return array_of_functions if self.empty?
    return self if array_of_functions.empty?
    self.flat_map.with_index do |element, index|
      if element.is_a? Proc
        compose(element, array_of_functions[index])
      else
        array_of_functions[index].curry.call(element)
      end
    end
  end

  private

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end

# y combinator
y = ->(generator) do
  ->(x) do
    ->(*args) do
      generator.call(x.call(x)).call(*args)
    end
  end.call(
    ->(x) do
      ->(*args) do
        generator.call(x.call(x)).call(*args)
      end
    end
  )
end

# factorial function in lambdas with y_comb

factorial = y.call(
  ->(callback) do
    ->(arg) do
      if arg.zero?
        1
      else
        arg * callback.call(arg - 1)
      end
    end
  end
)
# now we can do this:

[*1..10].apply([factorial])
[*1..10].apply([factorial]).apply([factorial])
