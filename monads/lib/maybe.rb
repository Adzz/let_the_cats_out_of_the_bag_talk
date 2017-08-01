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

  # the function arg is a function that takes in a non maybe value and
  # returns a wrapped maybe value.
  def bind(func_that_returns_maybe)
    return apply(func_that_returns_maybe).value if func_that_returns_maybe.is_a? Maybe
    map(func_that_returns_maybe)
  end

  # ^ this is okay but we still have to know about which function call to use when
  # we could remove that decision process automagically?

  def chain(next_link)
    if next_link.is_a? Maybe
      flatten_result(apply(next_link))
    else
      flatten_result(map(next_link))
    end
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
fifty               = Maybe.new(50)
times_two           = ->(x) { x * 2}
plus_four           = ->(x) { x + 4}
times_two_plus_four = ->(x) { (x * 2) + 4}
divide              = ->(x, y) { x / y }


returns_nil         = -> (x) { nil }


stumbling_block = -> (x){ Maybe.new(x + 1) }

# tada!
Maybe.new(5).bind(Maybe.new(stumbling_block)).bind(Maybe.new(stumbling_block))

# to make it a bit nicer so we dont have to think about whethe we need to apply.
# bind or map, we can use chain!

Maybe.new(5).chain(Maybe.new(stumbling_block)).chain(Maybe.new(stumbling_block))

# And we are still protected from nil!

Maybe.new(5).chain(Maybe.new(stumbling_block)).chain(returns_nil).chain(Maybe.new(stumbling_block))




















# =============================== AN ASIDE ===================================================#

# Arrays can now apply lists of functions to lists of values.
# Pretty powerful revelation!
# All of our programs could be lists of functions that get applied to a value

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
# we should ensure self is as long as array of functions really
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

  # flat_map [[[]]].flatten
  def bind(funcs_that_return_arrays_of_functions)
    self.flat_map do |element|
      funcs_that_return_arrays_of_functions.map do |func|
        apply([func])
      end.flatten
    end.flatten
  end

  private

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end





