class Maybe
  def initialize(value, maybe_klass = Maybe)
    @value = value
    @maybe_klass = maybe_klass
  end

  attr_reader :value

  # implements a functor interface
  # we curry the call to allow a function
  # with more than one arg to be partially applied
  # that allows us to do things like Maybe.new(1).map(-> (x, y){ x * y })
  # and have it not break
  def map(function)
    return self if value.nil?
    return maybe_klass.new(compose(value, function)) if value.is_a? Proc
    maybe_klass.new(function.curry.call(*value))
  end

  # implements the applicative interface
  # allows a way for wrapped functions to be applied
  def apply(maybe_function)
    return maybe_function if maybe_function.value.nil?
    map(maybe_function.value)
  end

  private

  attr_reader :maybe_klass

  def compose(f, g)
    lambda { |*args| f.call(g.call(*args))  }
  end
end


# Arrays can now apply lists of functions to lists of values.
# Pretty powerful revelation!
# All of our programs could be lists of functions that get applied to a value

class Array
  def apply(array_of_functions)
    return array_of_functions if self.empty?
    return self if array_of_functions.empty?
    self.flat_map do |element|
      array_of_functions.map { |func| func.call(element) }
    end
  end
end


# the interesting implication here is that we can write other objects
# that have the same interface, but do different things
# Maybe abstracts away a nil check,
# we could instead abstract away a cat feeding, for example.

# This is a simplified example of how a cat might
# be mapable - and include a different sort of computational context

class Cat
  def initialize(attrs)
    @attrs = attrs
  end

  def feed_and(function)
    new_attrs = function.call(@attrs)
    Cat.new(new_attrs.merge(hungry: false))
  end
end


walk_cat = -> (cat_attrs) { cat_attrs.merge({walked: true}) }
pet_cat  = -> (cat_attrs) { cat_attrs.merge({petted: true}) }

hungry_cat = Cat.new({hungry: true})

hungry_cat.feed_and(walk_cat) #=> Fed AND walked cat.
hungry_cat.feed_and(pet_cat) #=> Fed AND petted cat.
