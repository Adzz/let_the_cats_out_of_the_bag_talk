class Array
  def fmap(function)
    return self if self.compact.empty?
    self.map do|value|
      next value if value.nil?
      next compose(value, function) if value.is_a?(Proc)
      function.curry.call(value)
    end
  end

  def apply(array_of_functions)
    return self if array_of_functions.compact.empty?
    array_of_functions.flat_map do |func|
      fmap(func)
    end
  end

  # also implements the applicative interface
  # but differently
  def zip_apply(array_of_functions)
    return self if array_of_functions.compact.empty?
    self.flat_map.with_index do |value, index|
      next value if value.nil?
      next compose(value, array_of_functions[index]) if value.is_a? Proc
      array_of_functions[index].curry.call(value)
    end
  end

  private

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end













































# ====================== EXAMPLES ======================================== #

nothing   = [nil, nil]
fifty     = [50]

times_two = ->(x) { x * 2}
plus_four = ->(x) { x + 4}
divide    = ->(x, y) { x / y }
identity  = ->(x) { x }
stumble   = ->(x) { nil }
times_two_plus_four = ->(x){ (x * 2) + 4}



nothing.apply([times_two])
nothing.apply([times_two]).apply([plus_four])























# Applicative law 1. Identity
# we get the same answer as if we mapped an unwrapped function over
# the functor

fifty.fmap(times_two) == fifty.apply([times_two])











































# Next Law is that it's still associative
# in this sense:

fifty.apply([times_two]).apply([plus_four]) == fifty.apply([times_two_plus_four])






















# If we apply a list of functions to one value
# we get the result of each function being
# applied to each value:

fifty.apply([times_two, plus_four])

# But most importantly, we can see that our example
# from before now works!

[6].apply(fifty.fmap(divide).fmap(plus_four))


# This is pretty powerful, we can now
# chain partially applied functions
# without breaking anything!




































# But there is a stumbling block...
# What if the function we are applying RETURNS an array?

constructor = -> (x){ [x + 1] }

# this works okay - we get a nested array
[5].apply([constructor])


# but what if we try to chain that?
# [5].apply([constructor]).apply([constructor])


# Oh no. :(
# so we need something else....




































# ZIP APPLY EXAMPLE
# ===================

[*1..2].zip_apply([plus_four, times_two])




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







