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


# the interesting implication here is that we can write other objects
# that have the same interface, but do different things
# Maybe abstracts away a nil check,
# we could instead abstract away a cat feeding, for example.

# This is a simplified example of how a cat might
# be mapable - and include a different sort of computational context

class Cat < Struct.new(:attrs); end

class FoodBox
  def initialize(cat)
    @cat = cat
  end

  def map(action)
    return self if @cat.nil?
    # return CatBox.new(compose(cat, function)) if value.is_a? Proc
    new_cat = action.curry.call(@cat)
    new_cat.attrs.merge!({hungry: false})
    FoodBox.new(new_cat)
  end

  private

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end

walk_cat     = -> (cat) { Cat.new(cat.attrs.merge({walked: true})) }
pet_cat      = -> (cat) { Cat.new(cat.attrs.merge({petted: true})) }

hungry_cat = Cat.new({hungry: true})
fed_cat = FoodBox.new(hungry_cat)
fed_cat.map(walk_cat) #=> Fed AND walked cat.
fed_cat.map(pet_cat) #=> Fed AND petted cat.

is_rescue_cat  = -> (cat, rescue_list) { rescue_list.include? cat }

# example of a function to be curried
# also example of a function that doesn't return a cat - is this an issue? is this why we need monads?


add_two = ->(x){ x + 2}

find_middle_index = ->(array) { (0 + array.length - 1) / 2 }
check_value = ->(array) { array[index] == value }


# Some fun / dumb things you can do with the array of functions on array of values

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

[*1..10].apply([factorial, factorial])

# better use case would be to define our own objects and have them be operated on by lists of functions
#
#
#
# wowww is a hash an operational context? What happens if we monkey patch the hash class to have an apply
# what would that look like, what would be the consequences?
