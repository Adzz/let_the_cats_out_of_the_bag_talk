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

  def bind(funcs_that_return_arrays_of_functions)
    self.flat_map do |element|
      funcs_that_return_arrays_of_functions.map do |func|
        apply([func])
      end.flatten
    end.flatten
  end

  # ^ this is okay but we still have to know about which function call to use when
  # we could remove that decision process automagically?

  def chain(next_link)
    if next_link.is_a? Array
      apply(next_link).flatten
    else
      fmap(next_link).flatten
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
constructor = -> (x){ [x + 1] }
times_two_plus_four = ->(x){ (x * 2) + 4}
monad_identity = ->(x) { [x] }

# [5].apply([constructor]).apply([constructor]) #:(

# tada!

fifty.bind([constructor]).bind([constructor])





































# to make it a bit nicer so we dont have to think about whether we need to apply.
# bind or map, we can use chain!

fifty.chain([constructor]).chain(constructor)

# And we are still protected from nil!

fifty.chain([constructor]).chain(stumble).chain([stumble]).chain([constructor])














































# Monad Laws
#  Left Identity:
fifty.bind([plus_four]) == [50].fmap(plus_four)

# Right identity
fifty.bind([monad_identity]) == fifty










































