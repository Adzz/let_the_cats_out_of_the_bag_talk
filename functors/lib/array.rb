class Array
  def fmap(function)
    return self if self.compact.empty?
    self.map do|value|
      next value if value.nil?
      next compose(value, function) if value.is_a?(Proc)
      function.curry.call(value)
    end
  end

  private

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end



# go slow!



# ====================== EXAMPLES ======================================== #

nothing   = [nil, nil]
fifty     = [50]

times_two = ->(x) { x * 2}
plus_four = ->(x) { x + 4}
divide    = ->(x, y) { x / y }
identity  = ->(x) { x }
stumble   = ->(x) { nil }
times_two_plus_four = ->(x) { (x * 2) + 4}

# Example 1
# nil doesn't break stuff
# maintain the identity law

nothing.fmap(times_two)
nothing.fmap(times_two).fmap(plus_four)



















































# Example 2
# it does actually do stuff
# and it's chainable

fifty.fmap(times_two)
fifty.fmap(times_two).fmap(plus_four)










































# Example 3
# if we don't have enough params
# the function is partially applied

  # =============== ASIDE ==========================#
  # In case you aren't sure what it means to partially apply a function
  # if we have a function that takes two arguments
  # we can turn it into a function that takes one argument and returns a function that takes the other arg
  # meaning we can delay execution until we have all the arguments

  # Observe..

  # instead of:

  # def add(x, y)
  #   x + y
  # end

  #  we do this:
  # def add(x)
  #   ->(y){ x + y }
  # end

  # add_ten = add(10) => ->(y) { y + 10 }
  # add_ten.call(5) #=> 15
  # =============================================#



fifty.fmap(divide)

# we can tell because...

fifty.fmap(divide).first.call(10)

# .... And if we then fmap a function over that, those functions are composed (line 11)
fifty.fmap(divide).fmap(plus_four)

  # =============== ASIDE ==========================#
  # What does it mean to compose a function?
  # Combine one or more functions such that
  # when you execute the composed function it will
  # return the same result as if you executed them each separately

  # NB: COMPOSED FUNCTIONS WORK FROM RIGHT TO LEFT !


# Just to sort of prove they are composed
# if we access the inner value we and call it with 6
# then 6 gets added to 4, which makes 10, which we then divide 50 by

fifty.fmap(divide) # at this point we get [->(y) { 50 / y }]

fifty.fmap(divide).fmap(plus_four) # at this point we get: [->(y){ 50 / y + 4 } ]

fifty.fmap(divide).fmap(plus_four).first.call(6) # then we give it 6: [->(6) { 50 / 6 + 4 } ]

# Note our answer is because when we compose
# we execute from right to left - inner to out.








































# But there is a problem. we dont want to extract the value from the container ^
# Once we get a lambda inside our array, how can we apply it to a value?


fifty.fmap(divide).fmap(plus_four)

# What we really want to do is pass that now wrapped function to our wrapped value:


# [6].fmap(fifty.fmap(divide).fmap(plus_four))




































# Law 1
# if we map the id function over a functor,
# the functor that we get back should be the same as the original functor.

fifty.fmap(identity)
nothing.fmap(identity)


# Law 2
# composing two functions and then mapping the resulting function over a functor
# should be the same as first mapping one function over the functor and then mapping the other one.

fifty.fmap(times_two).fmap(plus_four) == fifty.fmap(times_two_plus_four)












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

# [*1..10].apply([factorial])
