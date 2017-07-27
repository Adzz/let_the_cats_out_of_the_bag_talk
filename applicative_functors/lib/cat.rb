
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

add_two = ->(x){ x + 2}

find_middle_index = ->(array) { (0 + array.length - 1) / 2 }
check_value = ->(array) { array[index] == value }






