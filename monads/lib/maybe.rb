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














