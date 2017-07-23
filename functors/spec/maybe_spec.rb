require 'pry'
require_relative '../lib/maybe'

# These are not production ready specs, they were for quick iteration

RSpec.describe Maybe do
  describe 'map' do
    let(:nothing) { Maybe.new(nil) }
    let(:add_four) {  -> (x) { x + 4 } }
    subject(:maybe) { Maybe.new(4) }

    context 'when maybe value is a value' do
      it 'applies the given function to the wrapped value' do
        expect(maybe.map(add_four)).to have_attributes(value: 8)
        expect(maybe.map(add_four).class).to eq Maybe
      end
    end

    context 'mapping a wrapped function over a function' do
      it 'creates a new wrapped function that does both of the functions combined' do
        maybe = Maybe.new(add_four)
        add_two = ->(x){ x + 2 }
        expect(maybe.map(add_two).value.call(1)).to eq 7
        expect(maybe.map(add_four).class).to eq Maybe
      end
    end

    context 'when value is a nothing' do
      it 'returns the wrapped nothing value' do
        expect(nothing.map(add_four)).to have_attributes(value: nil)
        expect(nothing.map(add_four).class).to eq Maybe
        expect(nothing.map(add_four)).to eq nothing
      end
    end

    context 'id' do
      it 'mapping id function just returns the original functor' do
        id_function = -> (x) { x }
        expect(maybe.map(id_function).class).to eq Maybe
        expect(maybe.map(id_function)).to have_attributes(value: 4)
        expect(Maybe.new(add_four).map(id_function).value.call(1)).to eq 5
      end
    end

    context 'associativity' do
      it 'grouping doesnt matter' do
        add_two = -> (x) { x + 2 }
        expect(maybe.map(add_two).map(add_four).value).to eq maybe.map(add_four).map(add_two).value
      end
    end

    context 'mapping a function that takes two args' do
      it 'partially applies the function' do
        times = -> (x, y) { x * y }
        expect(maybe.map(times).value.call(1)).to eq 4
      end
    end
  end


  describe '<*>' do
    it 'returns the value when ' do
    end
  end
end
