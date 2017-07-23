class Maybe
  def initialize(value)
    @value = value
  end

  attr_reader :value

  # implements a functor interface
  # we curry the call to allow a function
  # with more than one arg to be partially applied
  # that allows us to do things like Maybe.new(1).map(-> (x, y){ x * y })
  # and have it not break
  def map(function)
    return self if value.nil?
    return Maybe.new(compose(value, function)) if value.is_a? Proc
    Maybe.new(function.curry.call(*value))
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
